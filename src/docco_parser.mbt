///|
/// A parsed section from a docco-style source.
/// `docs` is the comment text (with markers stripped),
/// `code` is the raw code lines.
pub struct DoccoSection {
  docs : String
  code : String
} derive(Eq, Debug)

///|
/// Parse a source string (using `//` comment style) into docco sections.
/// Each section is a (comment block, code block) pair.
pub fn parse_docco(source : String) -> Array[DoccoSection] {
  let lines = source.split("\n").map(StringView::to_string).collect()
  let sections : Array[DoccoSection] = []
  let docs_buf : Array[String] = []
  let code_buf : Array[String] = []

  fn flush_section() {
    let docs = docs_buf.join("\n")
    let code = code_buf.join("\n")
    // Only emit section if there's something to show
    if docs != "" || code.trim_space() != "" {
      sections.push({ docs, code })
    }
    docs_buf.clear()
    code_buf.clear()
  }

  let mut in_comment = false
  for line in lines {
    if is_comment_line(line) {
      // Transitioning from code to comment -> flush if we have code
      if !in_comment && code_buf.length() > 0 {
        flush_section()
      }
      in_comment = true
      docs_buf.push(strip_comment(line))
    } else {
      // Transitioning from comment to code -> start new section
      if in_comment {
        in_comment = false
        // Don't flush yet; let code accumulate
      }
      code_buf.push(line)
    }
  }
  // Final flush
  flush_section()
  sections
}

///|
fn is_comment_line(line : String) -> Bool {
  let trimmed = line.trim_space().to_string()
  trimmed.has_prefix("//")
}

///|
fn strip_comment(line : String) -> String {
  let trimmed = line.trim_space().to_string()
  if trimmed.has_prefix("// ") {
    trimmed.unsafe_substring(start=3, end=trimmed.length())
  } else if trimmed == "//" {
    ""
  } else if trimmed.has_prefix("//") {
    trimmed.unsafe_substring(start=2, end=trimmed.length())
  } else {
    line
  }
}

///|
/// A fenced code block parsed from a docs string.
pub struct FencedBlock {
  lang : String
  renderer : String
  content : String
  start_pos : Int
  end_pos : Int
} derive(Eq, Debug)

///|
/// Parse extended fenced code blocks from a markdown text.
/// Returns list of blocks with their positions for replacement.
pub fn parse_fenced_blocks(text : String) -> Array[FencedBlock] {
  let blocks : Array[FencedBlock] = []
  let lines = text.split("\n").map(StringView::to_string).collect()
  let mut i = 0
  while i < lines.length() {
    let line = lines[i]
    if line.trim_space().has_prefix("```") {
      let fence_content = line.trim_space().to_string()
      let lang_spec = fence_content
        .unsafe_substring(start=3, end=fence_content.length())
        .trim_space()
        .to_string()
      let (lang, renderer) = parse_lang_spec(lang_spec)
      let start = i
      i = i + 1
      let content_lines : Array[String] = []
      while i < lines.length() {
        let cur = lines[i]
        if cur.trim_space().to_string() == "```" {
          blocks.push({
            lang,
            renderer,
            content: content_lines.join("\n"),
            start_pos: start,
            end_pos: i,
          })
          break
        }
        content_lines.push(cur)
        i = i + 1
      }
    }
    i = i + 1
  }
  blocks
}

///|
fn parse_lang_spec(spec : String) -> (String, String) {
  if spec.contains(".") {
    let parts = spec.split(".").map(StringView::to_string).collect()
    let lang = parts[0]
    let renderer = parts[1:].to_array().join(".")
    (lang, renderer)
  } else {
    (spec, "")
  }
}

///|
/// A segment of docs text: either plain markdown or a fenced block.
pub enum DocsSegment {
  Plain(String)
  Fenced(FencedBlock)
} derive(Eq, Debug)

///|
/// Split a docs string into alternating plain text and fenced block segments.
pub fn split_docs_segments(docs : String) -> Array[DocsSegment] {
  let result : Array[DocsSegment] = []
  let blocks = parse_fenced_blocks(docs)
  if blocks.is_empty() {
    if docs.trim_space() != "" {
      result.push(Plain(docs))
    }
    return result
  }
  let lines = docs.split("\n").map(StringView::to_string).collect()
  let mut cursor = 0
  for block in blocks {
    // Plain text before this block
    if block.start_pos > cursor {
      let plain_lines = lines[cursor:block.start_pos]
      let plain = plain_lines.to_array().join("\n")
      if plain.trim_space() != "" {
        result.push(Plain(plain))
      }
    }
    result.push(Fenced(block))
    cursor = block.end_pos + 1
  }
  // Remaining plain text
  if cursor < lines.length() {
    let rest = lines[cursor:].to_array().join("\n")
    if rest.trim_space() != "" {
      result.push(Plain(rest))
    }
  }
  result
}
