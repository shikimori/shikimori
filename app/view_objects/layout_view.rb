class LayoutView < ViewObjectBase
  instance_cache :styles, :hot_topics, :moderation_policy

  CUSTOM_CSS_ID = 'custom_css'

  def blank_layout?
    !!h.controller.instance_variable_get('@blank_layout')
  end

  def body_id
    "#{h.controller_name}_#{h.action_name}"
  end

  def body_class
    (controller_classes(h.controller_name) +
      (db_entries_controller? ? controller_classes('db_entries') : []) +
      (base_controller_name ? controller_classes(base_controller_name) : []) +
      (show_smileys? ? ['no-smileys'] : []) +
      [h.current_user&.preferences&.body_width || 'x1200']
    ).uniq.join(' ')
  end

  def localized_names
    ru_option?(:russian_names) ? :ru : :en
  end

  def localized_genres
    ru_option?(:russian_genres) ? :ru : :en
  end

  def custom_styles
    return if blank_layout?

    <<-CSS.squish.strip.html_safe
      <style id="#{CUSTOM_CSS_ID}" type="text/css">#{custom_css}</style>
    CSS
  end

  def user_data # rubocop:disable AbcSize
    user = h.current_user

    {
      id: user&.id,
      url: user&.url,
      is_moderator: !!(user&.forum_moderator? || user&.admin?),
      ignored_topics: user&.topic_ignores&.pluck(:topic_id) || [],
      ignored_users: user&.ignores&.pluck(:target_id) || [],
      is_day_registered: !!user&.day_registered?,
      is_week_registered: !!user&.week_registered?,
      is_ignore_copyright: h.ignore_copyright?,
      is_comments_auto_collapsed: !h.user_signed_in? ||
        user&.preferences&.comments_auto_collapsed?,
      is_comments_auto_loaded: !!user&.preferences&.comments_auto_loaded?
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
    ModerationPolicy.new h.current_user, h.locale_from_host, true
  end

private

  def base_controller_name
    return if h.controller.class.superclass == ApplicationController
    return if h.controller.class.superclass == ShikimoriController

    h.controller.class.superclass.name.to_underscore.sub(/_controller$/, '')
  end

  def controller_classes controller_name
    ["p-#{controller_name}", "p-#{controller_name}-#{h.action_name}"]
  end

  def ru_option? option_name
    I18n.russian? && h.ru_host? &&
      (!h.user_signed_in? || h.current_user&.preferences&.send(option_name))
  end

  def show_smileys?
    h.user_signed_in? && !h.current_user.preferences.show_smileys?
  end

  def db_entries_controller?
    h.controller.is_a? DbEntriesController
  end

  def custom_css # rubocop:disable AbcSize
    user = h.controller.instance_variable_get('@user')
    club = h.controller.instance_variable_get('@club')

    if h.user_signed_in? && !h.current_user.preferences.apply_user_styles
      try_style(h.current_user)
    elsif user && !user.censored_profile?
      try_style(user)
    else
      try_style(club) || try_style(h.current_user)
    end
  end

  def try_style target
    target.style.compiled_css if target&.style&.css&.strip.present?
  end
end
