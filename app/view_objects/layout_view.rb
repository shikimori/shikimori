class LayoutView < ViewObjectBase
  prepend ActiveCacher.instance
  instance_cache :styles, :hot_topics, :moderation_policy

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
    return if blank_layout?

    style = (
      h.controller.instance_variable_get('@user') || h.current_user
    )&.style

    if style&.css.present?
      <<-CSS.squish.strip.html_safe
        <style type="text/css">#{style.safe_css}</style>
      CSS
    end
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
    Topics::HotTopicsQuery.call(h.locale_from_domain).map do |topic|
      Topics::TopicViewFactory.new(true, true).build topic
    end
  end

  def moderation_policy
    ModerationPolicy.new h.current_user, true
  end

private

  def ru_option? option_name
    I18n.russian? && h.ru_domain? &&
      (!h.user_signed_in? || h.current_user&.preferences&.send(option_name))
  end
end
