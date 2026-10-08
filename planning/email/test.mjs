// Checks every message. Run: node build.mjs && node test.mjs
import { readFileSync } from 'node:fs';
import { buildMessage } from './render.mjs';

const layout = readFileSync('dist/layout.html', 'utf8');
const styles = JSON.parse(readFileSync('dist/styles.json', 'utf8'));
const rows = JSON.parse(readFileSync('messages.json', 'utf8'));
const vars = JSON.parse(readFileSync('samples.json', 'utf8'));
const env = { layout, styles, assetBase: 'https://inform9.com/email', supportEmail: 'support@inform9.com', postalAddress: '' };
const urls = { secure_link: 'https://inform9.com/r/x', share_link: 'https://inform9.com/s/x', payee_link: 'https://inform9.com/app/p/x', shares_link: 'https://inform9.com/payee/shares', app_link: 'https://inform9.com/app' };
let bad = 0;
const fail = (k, msg) => { bad++; console.log('FAIL', k, msg); };

for (const row of rows) {
  const evil = { ...vars, payee_name: '<script>alert(1)</script>', business_names: 'A & B "Co"' };
  const { subject, html, text } = buildMessage(row, { vars: evil, urls, unsubscribeUrl: 'https://inform9.com/u/x' }, env);
  if (/\{\{[#/]?\{?\w+\}?\}\}/.test(html + text + subject)) fail(row.event_key, 'unfilled placeholder');
  if (/<script/i.test(html)) fail(row.event_key, 'unescaped script');
  if (html.length > 10000) fail(row.event_key, 'html over 10 KB: ' + html.length);
  if (/href="(?!https:\/\/)/.test(html)) fail(row.event_key, 'non-https link');
  if (/—/.test(html + text)) fail(row.event_key, 'em dash');
  if (!subject || subject.length > 90) fail(row.event_key, 'subject length ' + subject.length);
}
// a missing value must throw
try { buildMessage(rows[0], { vars: {}, urls }, env); fail('missing', 'did not throw'); } catch { /* expected */ }
// a non-https link must throw
try { buildMessage(rows[0], { vars, urls: { secure_link: 'http://x.test' } }, env); fail('http', 'did not throw'); } catch { /* expected */ }
console.log(bad ? bad + ' failures' : rows.length + ' messages pass');
process.exit(bad ? 1 : 0);
