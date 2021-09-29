json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'animes/reviews/review',
    collection: [@resource],
    cached: ->(entry) { CacheHelper.keys entry }
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
