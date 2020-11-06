module JsExportsHelper
  # не выносить код в JsExports.instance !!!
  # при переносе туда из-за вызова h.capture из Draper::ViewHelpers контент
  # дублируется при наличии внутри кода вызова h.controller.render_to_string
  # (что происходит в BbCodes::Tags::DbEntriesTag)
  def sweep_js_exports &block
    html = capture &block
    JsExports::Supervisor.instance.sweep html
    html
  end
end
