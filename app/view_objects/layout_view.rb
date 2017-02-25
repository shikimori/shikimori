class LayoutView < ViewObjectBase
  prepend ActiveCacher.instance
  instance_cache :styles, :hot_topics, :moderation_policy

  CUSTOM_CSS_ID = 'custom_css'

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

  def custom_styles
    <<-CSS.squish.strip.html_safe
      <style id="#{CUSTOM_CSS_ID}" type="text/css">#{custom_css}</style>
    CSS
  end

  def user_data
    {
      id: h.current_user&.id,
      is_moderator: !!h.current_user&.moderator?,
      ignored_topics: h.current_user&.topic_ignores&.pluck(:topic_id) || [],
      ignored_users: h.current_user&.ignores&.pluck(:target_id) || []
    }
  end

  def hot_topics?
    h.params[:controller] == 'dashboards' ||
      (h.params[:controller] == 'topics' && h.params[:action] == 'index')
  end

  def hot_topics
    Topics::HotTopicsQuery.call(h.locale_from_host).map do |topic|
      Topics::TopicViewFactory.new(true, true).build topic
    end
  end

  def moderation_policy
    ModerationPolicy.new h.current_user, true
  end

private

  def ru_option? option_name
    I18n.russian? && h.ru_host? &&
      (!h.user_signed_in? || h.current_user&.preferences&.send(option_name))
  end

  def custom_css
    return if blank_layout?

    try_style(h.controller.instance_variable_get('@user')) ||
      try_style(h.controller.instance_variable_get('@club')) ||
        try_style(h.current_user)
  end

  def try_style target
    target.style.compiled_css if target&.style&.css&.strip.present?
  end
end
