json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'review',
    collection: [@resource],
    cached: ->(entry) { CacheHelper.keys entry },
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
