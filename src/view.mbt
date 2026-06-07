///|
using @respo_node {
  div,
  span,
  button,
  pre,
  code,
  static_style,
  create_element,
  text_node,
  textarea,
  type RespoNode,
  type RespoEvent,
  type DispatchFn,
  type RespoCommonError,
}

///|
using @css {respo_style}

///|
pub enum GlobalEvent {}

///|
fn view(
  store : Store,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  div(
    class_name=@respo.ui_global,
    style=respo_style(background_color=Hsl(0, 0, 97)),
    [
      comp_top_bar(store),
      comp_sample_bar(store),
      match store.mode {
        Markdown => comp_markdown_view(store)
        Docco => comp_docco_view(store)
      },
    ],
  )
}

///|
fn comp_top_bar(
  store : Store,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let on_markdown = fn(
    _e : RespoEvent,
    d : DispatchFn[ActionOp],
  ) -> Unit raise RespoCommonError {
    d.run(SwitchTab(Markdown))
  }
  let on_docco = fn(
    _e : RespoEvent,
    d : DispatchFn[ActionOp],
  ) -> Unit raise RespoCommonError {
    d.run(SwitchTab(Docco))
  }
  div(class_name="tab-bar", [
    button(
      inner_text="Markdown",
      class_name=if store.mode == Markdown {
        "tab-btn active"
      } else {
        "tab-btn"
      },
      on_click=on_markdown,
    ),
    button(
      inner_text="Docco",
      class_name=if store.mode == Docco { "tab-btn active" } else { "tab-btn" },
      on_click=on_docco,
    ),
  ])
}

///|
fn comp_sample_bar(
  store : Store,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let btns : Array[RespoNode[ActionOp, GlobalEvent]] = [
    span(inner_text="示例:", class_name="sample-label", []),
  ]
  for i, s in samples {
    let idx = i
    let on_click_fn = fn(
      _e : RespoEvent,
      d : DispatchFn[ActionOp],
    ) -> Unit raise RespoCommonError {
      d.run(SelectSample(idx))
    }
    btns.push(
      button(
        inner_text=s.name,
        class_name=if store.active_sample == idx {
          "sample-btn active"
        } else {
          "sample-btn"
        },
        on_click=on_click_fn,
      ),
    )
  }
  div(class_name="sample-bar", btns)
}

///|
fn comp_markdown_view(store : Store) -> RespoNode[ActionOp, GlobalEvent] {
  div(class_name="markdown-view", [
    textarea(
      class_name="markdown-textarea",
      value=store.content,
      spellcheck=false,
      readonly_=true,
    ),
  ])
}

///|
fn comp_docco_view(
  store : Store,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let sections = parse_docco(store.content)
  if sections.is_empty() {
    return div(class_name="empty-docco", [
      span(inner_text="选择一个示例，或粘贴带注释的源代码", []),
      span(
        inner_text="// 注释行 → 左侧文档   非注释行 → 右侧代码",
        class_name="hint",
        [],
      ),
    ])
  }
  let rows : Array[RespoNode[ActionOp, GlobalEvent]] = []
  for sec_idx, section in sections {
    rows.push(comp_docco_section(section, sec_idx, store))
  }
  div(class_name="docco-view", rows)
}

///|
fn comp_docco_section(
  section : DoccoSection,
  sec_idx : Int,
  store : Store,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let segments = split_docs_segments(section.docs)

  // Left column: only plain text rendered as markdown
  let docs_children : Array[RespoNode[ActionOp, GlobalEvent]] = []
  for seg in segments {
    match seg {
      Plain(text) => {
        let html = md_to_html(text)
        docs_children.push(div(innerHTML=html, []))
      }
      Fenced(_) => () // fenced blocks move to right column
    }
  }

  // Right column: source code + fenced interactive blocks from docs
  let code_children : Array[RespoNode[ActionOp, GlobalEvent]] = []
  let trimmed_code = section.code.trim(char_set=" \n\r\t").to_owned()
  if trimmed_code != "" {
    code_children.push(pre(inner_text=trimmed_code))
  }
  for seg_idx, seg in segments {
    match seg {
      Plain(_) => ()
      Fenced(block) => {
        let block_id = "\{sec_idx}:\{seg_idx}"
        let run_output = store.run_outputs.get(block_id)
        let show_source = store.show_source.get(block_id).unwrap_or(false)
        code_children.push(
          comp_fenced_inline(block, block_id, run_output, show_source),
        )
      }
    }
  }

  div(class_name="docco-section", [
    div(class_name="docco-docs", docs_children),
    div(class_name="docco-code", code_children),
  ])
}

///|
/// Render a fenced code block in the right (code) column.
fn comp_fenced_inline(
  block : FencedBlock,
  block_id : String,
  run_output : String?,
  show_source : Bool,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let lang_label = if block.renderer != "" {
    "\{block.lang}.\{block.renderer}"
  } else {
    block.lang
  }
  match block.renderer {
    "echarts" => comp_echarts_inline(block, block_id, show_source, lang_label)
    "run" => comp_run_inline(block, block_id, run_output, lang_label)
    "demo" => comp_demo_inline(block, block_id, run_output, lang_label)
    _ =>
      div(class_name="ext-block", [
        div(class_name="ext-header", [
          span(inner_text=lang_label, class_name="ext-lang", []),
        ]),
        div(class_name="ext-body", [pre(inner_text=block.content)]),
      ])
  }
}

///|
fn comp_echarts_inline(
  block : FencedBlock,
  block_id : String,
  show_source : Bool,
  lang_label : String,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let bid = block_id
  let on_toggle = fn(
    _e : RespoEvent,
    d : DispatchFn[ActionOp],
  ) -> Unit raise RespoCommonError {
    d.run(ToggleSource(bid))
  }
  let body = if show_source {
    div(class_name="ext-body", [pre(inner_text=block.content)])
  } else {
    let svg = echarts_render_svg(block.content)
    if svg.has_prefix("ERROR:") {
      div(class_name="ext-body", [
        span(
          inner_text="Error: \{svg.unsafe_substring(start=6, end=svg.length())}",
          style=respo_style(color=Hsl(0, 70, 55), font_size=12),
          [],
        ),
      ])
    } else {
      div(class_name="ext-chart-container", innerHTML=svg, [])
    }
  }
  div(class_name="ext-block", [
    div(class_name="ext-header", [
      span(inner_text=lang_label, class_name="ext-lang", []),
      div(class_name="ext-actions", [
        button(
          inner_text=if show_source { "Chart" } else { "Source" },
          class_name="ext-toggle-btn",
          on_click=on_toggle,
        ),
      ]),
    ]),
    body,
  ])
}

///|
fn comp_run_inline(
  block : FencedBlock,
  block_id : String,
  run_output : String?,
  lang_label : String,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let bid = block_id
  let code_content = block.content
  let on_run = fn(
    _e : RespoEvent,
    d : DispatchFn[ActionOp],
  ) -> Unit raise RespoCommonError {
    let output = js_eval_capture(code_content)
    d.run(SetRunOutput(bid, output))
  }
  let output_el : RespoNode[ActionOp, GlobalEvent] = match run_output {
    None => div([])
    Some(out) =>
      div(
        class_name="ext-output",
        innerHTML=escape_html(if out == "" { "(no output)" } else { out }),
        [],
      )
  }
  div(class_name="ext-block", [
    div(class_name="ext-header", [
      span(inner_text=lang_label, class_name="ext-lang", []),
      div(class_name="ext-actions", [
        button(inner_text="▶ Run", class_name="ext-run-btn", on_click=on_run),
      ]),
    ]),
    div(class_name="ext-body", [pre(inner_text=block.content)]),
    output_el,
  ])
}

///|
fn comp_demo_inline(
  block : FencedBlock,
  block_id : String,
  run_output : String?,
  lang_label : String,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  let bid = block_id
  let fake_out = moonbit_fake_output(block.content)
  let on_run = fn(
    _e : RespoEvent,
    d : DispatchFn[ActionOp],
  ) -> Unit raise RespoCommonError {
    d.run(SetRunOutput(bid, fake_out))
  }
  let output_el : RespoNode[ActionOp, GlobalEvent] = match run_output {
    None => div([])
    Some(out) => div(class_name="ext-output", innerHTML=escape_html(out), [])
  }
  div(class_name="ext-block", [
    div(class_name="ext-header", [
      span(inner_text=lang_label, class_name="ext-lang", []),
      div(class_name="ext-actions", [
        button(
          inner_text="▶ Run (Demo)",
          class_name="ext-run-btn moonbit",
          on_click=on_run,
        ),
      ]),
    ]),
    div(class_name="ext-body", [pre(inner_text=block.content)]),
    output_el,
  ])
}

///|
fn escape_html(s : String) -> String {
  s
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\n", new="<br>")
}
