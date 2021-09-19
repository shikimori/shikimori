json.id @resource.id
json.html JsExports::Supervisor.instance.sweep(
  render(
    partial: 'reviews/review',
    locals: {
      review: @resource
    },
    formats: %i[html]
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
