// Renders every message with sample values into dist/preview/ and writes dist/templates.seed.sql.
// Run after build.mjs: node preview.mjs
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { buildMessage } from './render.mjs';

const layout = readFileSync('dist/layout.html', 'utf8');
const styles = JSON.parse(readFileSync('dist/styles.json', 'utf8'));
const rows = JSON.parse(readFileSync('messages.json', 'utf8'));
const vars = JSON.parse(readFileSync('samples.json', 'utf8'));
const env = { layout, styles, assetBase: '../../assets', supportEmail: 'support@inform9.com', postalAddress: '' };
const urls = { secure_link: 'https://inform9.com/r/sample', share_link: 'https://inform9.com/s/sample', payee_link: 'https://inform9.com/app/payees/sample', shares_link: 'https://inform9.com/payee/shares', app_link: 'https://inform9.com/app' };
const extraFor = {
  request: [{ label: 'Decline', url: urls.secure_link + '/decline' }, { label: 'I am not the right person', url: urls.secure_link + '/decline?why=wrong' }],
  reminder: [{ label: 'Decline', url: urls.secure_link + '/decline' }, { label: 'I am not the right person', url: urls.secure_link + '/decline?why=wrong' }, { label: 'Stop reminders', url: urls.secure_link + '/stop-reminders' }],
  share_waiting: [{ label: 'Stop W-9s from this sender or from everyone', url: 'https://inform9.com/optout/sample' }],
};

mkdirSync('dist/preview', { recursive: true });
const q = (s) => (s == null ? 'NULL' : "'" + String(s).replace(/'/g, "''") + "'");
const sql = [];
const index = [];
for (const row of rows) {
  const { subject, html, text } = buildMessage(row, { vars, urls, extraLinks: extraFor[row.event_key], unsubscribeUrl: 'https://inform9.com/unsubscribe/sample' }, env);
  writeFileSync(`dist/preview/${row.event_key}.html`, html);
  writeFileSync(`dist/preview/${row.event_key}.txt`, text);
  index.push(`<li><a href="${row.event_key}.html">${row.event_key}</a> (${html.length} bytes) ${row.enabled ? '' : '(disabled)'}</li>`);
  const all = [row.subject, row.heading, row.body, row.button_label || '', row.footnote || '', ...row.details.map((d) => d.value)].join(' ');
  const ph = [...new Set([...all.matchAll(/\{\{(\w+)\}\}/g)].map((m) => m[1]))];
  sql.push(`INSERT INTO email_templates (event_key, layout, audience, subject, heading, body, button_label, button_url_key, details, footnote, show_code, unsubscribe, placeholders, enabled, version, updated_at) VALUES (${[q(row.event_key), q(row.layout), q(row.audience), q(row.subject), q(row.heading), q(row.body), q(row.button_label), q(row.button_url_key), q(JSON.stringify(row.details)), q(row.footnote), row.show_code ? 1 : 0, row.unsubscribe ? 1 : 0, q(JSON.stringify(ph)), row.enabled ? 1 : 0, 1, 0].join(', ')});`);
}
writeFileSync('dist/preview/index.html', `<!doctype html><meta charset="utf-8"><title>Email previews</title><ul>${index.join('')}</ul>`);
writeFileSync('dist/templates.seed.sql', sql.join('\n') + '\n');
console.log(rows.length + ' messages rendered');
