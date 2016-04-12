class LayoutView < ViewObjectBase
  prepend ActiveCacher.instance
  instance_cache :background

  def blank_layout?
    !!h.controller.instance_variable_get('@blank_layout')
  end

  def background_styles
    return if blank_layout?
    return unless background

    if background =~ %r{^https?://}
      css = "background: url(#{background}) fixed no-repeat;"
    else
      css = "background: #{background};"
    end

    Misc::SanitizeEvilCss.call css
  end

private

  def background
    object_with_background = h.controller.instance_variable_get('@user')
    (object_with_background || h.current_user)&.preferences&.body_background
  end
end
