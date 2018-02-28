json.content JsExports::Supervisor.instance.sweep(render(
  partial: 'moderations/anime_video_reports/anime_video_report',
  object: @resource,
  formats: :html
))

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
