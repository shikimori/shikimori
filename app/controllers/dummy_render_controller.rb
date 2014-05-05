# 1. render_to_string не работае внутри rabl шаблонов
# 2. вызывать render_to_string для текущего контроллера чревато изменением content-type ответа на запрос
#    баг рельс это или фича, я не знаю. но сделал такую заглушку, чтобы корректно отрабатывал рендер
class DummyRenderController < ActionController::Base
  def initialize controller
    @__view_context = controller.view_context
  end

  def view_context
    @__view_context
  end
end
