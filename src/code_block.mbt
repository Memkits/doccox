///|
/// Returns a fixed fake output for a MoonBit demo block.
pub fn moonbit_fake_output(code_text : String) -> String {
  if code_text.contains("sum_tree") {
    "15"
  } else if code_text.contains("describe") {
    "zero\nsingle digit\ndouble digit\nlarge number"
  } else if code_text.contains("average") {
    "平均值: 139.833..."
  } else if code_text.contains("println") {
    let lines : Array[String] = []
    for line in code_text.split("\n") {
      let s = line.trim(char_set=" ").to_owned()
      if s.has_prefix("println(") && s.contains("// =>") {
        let parts = s.split("// =>").map(StringView::to_owned).collect()
        if parts.length() >= 2 {
          lines.push(parts[1].trim(char_set=" ").to_owned())
        }
      }
    }
    if lines.is_empty() {
      "Hello from MoonBit!"
    } else {
      lines.join("\n")
    }
  } else {
    "(MoonBit demo output)"
  }
}
