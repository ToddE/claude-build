// inform9 email rendering. No dependencies. Runs in Node (build, tests) and in a Worker (send).
// Message text uses {{name}} values. Every value is HTML-escaped. Only the application builds raw HTML.

export const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');

export function safeUrl(u) {
  if (!/^https:\/\/[^\s"'<>]+$/i.test(String(u))) throw new Error('Link must be https: ' + u);
  return String(u);
}

export function fill(str, vars) {
  return String(str).replace(/\{\{(\w+)\}\}/g, (_, k) => {
    if (!(k in vars)) throw new Error('Missing value: ' + k);
    return String(vars[k]);
  });
}

function sections(html, vals) {
  let prev;
  do {
    prev = html;
    html = html.replace(/\{\{#(\w+)\}\}([\s\S]*?)\{\{\/\1\}\}/g, (_, k, inner) => (vals[k] ? inner : ''));
  } while (html !== prev);
  return html;
}

function substitute(html, vals) {
  return html
    .replace(/\{\{\{(\w+)\}\}\}/g, (_, k) => (k in vals ? String(vals[k]) : ''))
    .replace(/\{\{(\w+)\}\}/g, (_, k) => (k in vals ? esc(vals[k]) : ''));
}

// row: one email_templates row. ctx: { vars, urls, extraLinks, unsubscribeUrl }.
// env: { layout, styles, assetBase, supportEmail, postalAddress }.
export function buildMessage(row, ctx, env) {
  const st = env.styles;
  const vars = { support_email: env.supportEmail, ...ctx.vars };
  const details = typeof row.details === 'string' ? JSON.parse(row.details || '[]') : row.details || [];

  const subject = fill(row.subject, vars).replace(/\s+/g, ' ').trim();
  const heading = fill(row.heading, vars);
  const paras = fill(row.body, vars).split(/\n\n+/);
  const bodyHtml = paras.map((p) => `<p class="p" style="${st.p}">${esc(p).replace(/\n/g, '<br>')}</p>`).join('');

  const detailsHtml = details.length
    ? `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" class="details" style="${st.details}">` +
      details
        .map((d) => `<tr><td class="dl" style="${st.dl}">${esc(d.label)}</td><td class="dv" style="${st.dv}">${esc(fill(d.value, vars))}</td></tr>`)
        .join('') +
      '</table>'
    : '';

  const buttonUrl = row.button_url_key ? safeUrl(ctx.urls[row.button_url_key]) : '';
  const extra = (ctx.extraLinks || []).map((l) => `<a href="${esc(safeUrl(l.url))}" class="link" style="${st.link}">${esc(l.label)}</a>`);
  const extraHtml = extra.length ? `<p class="small" style="${st.small}">${extra.join(' &nbsp;&middot;&nbsp; ')}</p>` : '';
  const footnote = row.footnote ? fill(row.footnote, vars) : '';

  const vals = {
    subject,
    preheader: paras[0].slice(0, 110),
    asset_base: env.assetBase,
    heading,
    body_html: bodyHtml,
    code: row.show_code ? vars.code : '',
    details_html: detailsHtml,
    button_url: buttonUrl,
    button_label: row.button_label || '',
    extra_links_html: extraHtml,
    footnote,
    support_email: env.supportEmail,
    postal_address: env.postalAddress || '',
    unsubscribe_url: row.unsubscribe && ctx.unsubscribeUrl ? safeUrl(ctx.unsubscribeUrl) : '',
  };
  const html = substitute(sections(env.layout, vals), vals);

  const text = [
    heading,
    '',
    paras.join('\n\n'),
    row.show_code ? '\n' + vars.code : '',
    details.length ? '\n' + details.map((d) => `${d.label}: ${fill(d.value, vars)}`).join('\n') : '',
    buttonUrl ? `\n${row.button_label}: ${buttonUrl}` : '',
    ...(ctx.extraLinks || []).map((l) => `${l.label}: ${l.url}`),
    footnote ? '\n' + footnote : '',
    '\n--\ninform9 | ' + env.supportEmail + (env.postalAddress ? '\n' + env.postalAddress : ''),
  ]
    .filter((x) => x !== '')
    .join('\n')
    .replace(/\n{3,}/g, '\n\n');

  return { subject, html, text };
}
