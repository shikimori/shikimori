module JsExportsHelper
  # не выносить код в JsExports.instance !!!
  # при переносе туда из-за вызова h.capture из Draper::ViewHelpers контент
  # дублируется при наличии внутри кода вызова h.controller.render_to_string
  # (что происходит в BbCodes::Tags::DbEntriesTag)
  def sweep_js_exports(&)
    html = capture(&)
    JsExports::Supervisor.instance.sweep current_user, html
    html
  end
end
