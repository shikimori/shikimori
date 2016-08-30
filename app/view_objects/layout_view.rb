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
    ru_option?(:russian_names) ? 'localized_names-ru' : 'localized_names-en'
  end

  def localized_genres_class
    ru_option?(:russian_genres) ? 'localized_genres-ru' : 'localized_genres-en'
  end

  # rubocop:disable MethodLength
  def background_styles
    return if blank_layout?
    return unless background

    if background =~ %r{\A(https?:)?//}
      url = UrlGenerator.instance.camo_url background
      css = "background: url(#{url}) fixed no-repeat;"
    else
      fixed_background = background.gsub(BbCodes::UrlTag::REGEXP) do
        UrlGenerator.instance.camo_url $LAST_MATCH_INFO[:url]
      end
      css = "background: #{fixed_background};"
    end

    Misc::SanitizeEvilCss.call css
  end
  # rubocop:enable MethodLength

  def user_data
    {
      id: h.current_user&.id,
      is_moderator: h.current_user&.moderator?
    }
  end

private

  def background
    object_with_background = h.controller.instance_variable_get('@user')
    (object_with_background || h.current_user)&.preferences&.body_background
  end

  def ru_option? option_name
    I18n.russian? && h.ru_domain? &&
      (!h.user_signed_in? || h.current_user&.preferences&.send(option_name))
  end
end
