json.id @resource.id
json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'reviews/review',
    locals: {
      review: @resource,
      is_show: true
    },
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
