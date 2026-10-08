// Build step. Reads email.css and layout.html, inlines the CSS, and writes dist/.
// Run: node build.mjs
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';

const css = readFileSync('email.css', 'utf8').replace(/\/\*[\s\S]*?\*\//g, '');
const media = [];
const base = css.replace(/@media[^{]+\{(?:[^{}]*\{[^{}]*\})*[^{}]*\}/g, (m) => (media.push(m.replace(/\s*\n\s*/g, '')), ''));

// class name -> declarations (rules apply in file order)
const styles = {};
for (const [, sel, decl] of base.matchAll(/([^{}]+)\{([^{}]*)\}/g)) {
  const d = decl.trim().replace(/\s*;\s*/g, ';').replace(/;$/, '');
  for (const s of sel.split(',')) {
    const name = s.trim().replace(/^\./, '');
    styles[name] = styles[name] ? styles[name] + ';' + d : d;
  }
}
// names with dashes are available under a camel key too, for fragments built in code
for (const k of Object.keys(styles)) styles[k.replace(/-(\w)/g, (_, c) => c.toUpperCase())] = styles[k];

let layout = readFileSync('layout.html', 'utf8');
layout = layout.replace(/<(\w+)([^>]*?)\sclass="([^"]+)"([^>]*)>/g, (tag, name, pre, cls, post) => {
  const decl = cls.split(/\s+/).map((c) => styles[c]).filter(Boolean).join(';');
  if (!decl) return tag;
  const m = (pre + post).match(/\sstyle="([^"]*)"/);
  const rest = (pre + post).replace(/\sstyle="[^"]*"/, '');
  return `<${name}${rest} class="${cls}" style="${decl}${m ? ';' + m[1] : ''}">`;
});
layout = layout.replace('/*MEDIA*/', media.join('')).replace(/>\s*\n\s*</g, '><').replace(/\n/g, '');

mkdirSync('dist', { recursive: true });
writeFileSync('dist/layout.html', layout);
writeFileSync('dist/styles.json', JSON.stringify(styles));
console.log(`layout ${layout.length} bytes, ${Object.keys(styles).length} style keys, ${media.length} media blocks`);
