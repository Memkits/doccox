///|
pub enum TabMode {
  Markdown
  Docco
} derive(Eq, Show, ToJson, @json.FromJson)

///|
pub struct Store {
  mode : TabMode
  content : String
  active_sample : Int
  /// Per-block run outputs keyed by block_id (section_idx:block_idx)
  run_outputs : Map[String, String]
  /// Per-block show_source toggle (for charts)
  show_source : Map[String, Bool]
  states : @respo.RespoStatesTree
} derive(ToJson, @json.FromJson, Eq)

///|
impl Default for Store with fn default() -> Store {
  {
    mode: Docco,
    content: samples[0].content,
    active_sample: 0,
    run_outputs: {},
    show_source: {},
    states: @respo.RespoStatesTree::default(),
  }
}

///|
pub enum ActionOp {
  StatesChange(@respo.RespoUpdateState)
  SwitchTab(TabMode)
  SetContent(String)
  SelectSample(Int)
  SetRunOutput(String, String)
  ToggleSource(String)
}

///|
impl @respo_node.RespoAction for ActionOp with fn build_states_action(
  cursor,
  a,
  j,
) {
  StatesChange({ cursor, data: a.map(@dom_ffi.js_obscure_to_v), backup: j })
}

///|
impl Show for ActionOp with fn output(self, logger) -> Unit {
  let s = match self {
    StatesChange(_) => "StatesChange"
    SwitchTab(m) => "SwitchTab(\{m})"
    SetContent(_) => "SetContent(...)"
    SelectSample(i) => "SelectSample(\{i})"
    SetRunOutput(k, _) => "SetRunOutput(\{k})"
    ToggleSource(k) => "ToggleSource(\{k})"
  }
  logger.write_string(s)
}

///|
pub fn Store::update(self : Store, op : ActionOp) -> Store {
  match op {
    StatesChange(states) => { ..self, states: self.states.set_in(states) }
    SwitchTab(m) => { ..self, mode: m }
    SetContent(c) => { ..self, content: c, run_outputs: {}, show_source: {} }
    SelectSample(i) => {
      let sample = samples[i % samples.length()]
      {
        ..self,
        active_sample: i,
        content: sample.content,
        run_outputs: {},
        show_source: {},
      }
    }
    SetRunOutput(k, v) => {
      let new_map = {}
      for kk, vv in self.run_outputs {
        new_map[kk] = vv
      }
      new_map[k] = v
      { ..self, run_outputs: new_map }
    }
    ToggleSource(k) => {
      let new_map = {}
      for kk, vv in self.show_source {
        new_map[kk] = vv
      }
      let cur = new_map.get(k).unwrap_or(false)
      new_map[k] = !cur
      { ..self, show_source: new_map }
    }
  }
}
