class Rabl::Engine
  # кастомный render_to_string, не затрагивающий основной контроллер
  def render_to_string options = {}
    render_controller = DummyRenderController.new controller
    render_controller.request = controller.request
    render_controller.render_to_string options
  end
end

Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root = false
end
