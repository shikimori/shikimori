json.id @resource.id
json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'reviews/review',
    locals: {
      review: @resource,
      is_show: true
    },
    cached: ->(entry) { CacheHelper.keys entry, :is_show },
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
