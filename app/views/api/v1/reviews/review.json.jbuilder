json.id @resource.id
json.html JsExports::Supervisor.instance.sweep(
  render(
    partial: 'reviews/review',
    locals: {
      review: @resource,
      is_show: true,
      is_buttons: true
    },
    formats: %i[html]
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
