///|
let app_store_key : String = "doccox-v1"

///|
fn main {
  let window = @dom_ffi.window()
  if window.document().query_selector(".app") is Some(mount_target) {
    let mount_target = mount_target.reinterpret_as_node()
    let app : @respo.RespoApp[Store] = {
      store: Ref(@respo.try_load_storage(app_store_key)),
      mount_target,
      storage_key: app_store_key,
    }
    app.backup_model_beforeunload()
    app.render_loop(() => view(app.store.val), op => {
      app.store.val = app.store.val.update(op)
    })
  } else {
    @dom_ffi.log("No .app mount target found")
  }
}
