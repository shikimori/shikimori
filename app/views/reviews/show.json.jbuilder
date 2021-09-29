json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'animes/reviews/review',
    collection: [@resource],
    locals: { is_show: true },
    cached: ->(entry) { CacheHelper.keys entry }
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
