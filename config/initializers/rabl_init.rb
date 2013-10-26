class Rabl::Engine
  # кастомный render_to_string, не затрагивающий основной контроллер
  def render_to_string(options)
    DummyRenderController.new(controller).render_to_string options
  end
end

Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root = false
end
