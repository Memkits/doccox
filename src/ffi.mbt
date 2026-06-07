///|
/// Render an ECharts option JSON string into an SVG string.
/// Uses echarts.init with ssr:true (ECharts 5.3+).
pub extern "js" fn echarts_render_svg(option_json : String) -> String =
  #| (optionJson) => {
  #|   try {
  #|     const option = JSON.parse(optionJson);
  #|     const chart = echarts.init(null, null, {
  #|       renderer: 'svg', ssr: true, width: 520, height: 300,
  #|     });
  #|     chart.setOption(option);
  #|     const svg = chart.renderToSVGString();
  #|     chart.dispose();
  #|     return svg;
  #|   } catch(e) {
  #|     return "ERROR:" + String(e);
  #|   }
  #| }

///|
/// Execute JavaScript code string. Captures console.log output and returns it.
/// Returns output lines joined by newlines, or "ERROR: ..." on exception.
pub extern "js" fn js_eval_capture(code : String) -> String =
  #| (code) => {
  #|   const logs = [];
  #|   const origLog = console.log;
  #|   console.log = (...args) => {
  #|     logs.push(args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' '));
  #|     origLog(...args);
  #|   };
  #|   try {
  #|     const fn = new Function(code);
  #|     const result = fn();
  #|     if (result !== undefined) logs.push(String(result));
  #|   } catch(e) {
  #|     logs.push("ERROR: " + String(e));
  #|   } finally {
  #|     console.log = origLog;
  #|   }
  #|   return logs.join('\n');
  #| }

///|
/// Convert a Markdown string to HTML using marked.js.
pub extern "js" fn md_to_html(text : String) -> String =
  #| (text) => {
  #|   try {
  #|     if (typeof marked !== 'undefined') {
  #|       return marked.parse(text, { breaks: true, gfm: true });
  #|     }
  #|     return '<pre>' + text.replace(/&/g,'&amp;').replace(/</g,'&lt;') + '</pre>';
  #|   } catch(e) {
  #|     return '<p>' + String(e) + '</p>';
  #|   }
  #| }
