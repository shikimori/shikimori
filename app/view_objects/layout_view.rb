class LayoutView < ViewObjectBase
  prepend ActiveCacher.instance
  instance_cache :background

  def blank_layout?
    !!h.controller.instance_variable_get('@blank_layout')
  end

  def body_id
    "#{h.controller_name}_#{h.action_name}"
  end

  def localized_names_class
    ru_names? ? 'localized_names-ru' : 'localized_names-en'
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

  def ru_names?
    I18n.russian? && h.ru_domain? &&
      (!h.user_signed_in? || h.current_user&.preferences&.russian_names)
  end
end
