class LayoutView < ViewObjectBase
  instance_cache :styles, :hot_topics, :moderation_policy, :moderation_hot_stat

  CUSTOM_CSS_ID = 'custom_css'

  def blank_layout?
    !!h.controller.instance_variable_get(:@blank_layout)
  end

  def body_id
    "#{h.controller_name}_#{h.action_name}"
  end

  def body_class
    (controller_classes(h.controller_name) +
      (db_entries_controller? ? controller_classes('db_entries') : []) +
      (base_controller_name ? controller_classes(base_controller_name) : []) +
      (is_show_smileys? ? ['no-smileys'] : []) +
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
    return if Rails.env.development? && h.params.key?(:no_menu)

    style = custom_style
    style.compile! unless !style || style.compiled?

    <<-CSS.squish.strip.html_safe
      <style id="#{CUSTOM_CSS_ID}" type="text/css">#{custom_style&.compiled_css}</style>
    CSS
  end

  def user_data # rubocop:disable all
    user = h.current_user

    {
      id: user&.id,
      url: user&.url,
      is_moderator: !!(user&.forum_moderator? || user&.admin?),
      ignored_topics: user&.topic_ignores&.pluck(:topic_id) || [],
      ignored_users: user&.ignores&.pluck(:target_id) || [],
      # ignored_users: ignored_users? ? user.ignores.pluck(:target_id) : [],
      is_day_registered: !!user&.day_registered?,
      is_week_registered: !!user&.week_registered?,
      is_comments_auto_collapsed: !h.user_signed_in? ||
        !!user&.preferences&.comments_auto_collapsed?,
      is_comments_auto_loaded: !!user&.preferences&.comments_auto_loaded?
    }
  end

  def hot_topics?
    (h.params[:controller] == 'dashboards' && !h.current_user&.preferences&.dashboard_type_new?) ||
      (h.params[:controller] == 'topics' && h.params[:action] == 'index') # ||
      # (h.params[:controller] == 'tests' && h.params[:action] == 'news')
  end

  def hot_topics
    Topics::HotTopicsQuery.call(limit: 8)
      .map { |topic| Topics::TopicViewFactory.new(true, true).build topic }
  end

  def moderation_hot_stat # rubocop:disable all
    stats = (
      [
        {
          count: moderation_policy.abuse_requests_total_count,
          threshold: 0, # 3,
          url: h.moderations_bans_url,
          label: i18n_i('Forum')
        }, {
          count: moderation_policy.critiques_count,
          threshold: 0, # 3,
          url: h.moderations_critiques_url,
          label: i18n_i('Critique', :other)
        }, {
          count: moderation_policy.collections_count,
          threshold: 0, # 3,
          url: h.moderations_collections_url,
          label: i18n_i('Collection', :other)
        }, {
          count: moderation_policy.news_count,
          threshold: 0, # 5,
          url: h.moderations_news_index_url,
          label: i18n_i('News', :other)
        }, {
          count: moderation_policy.articles_count,
          threshold: 0, # 1,
          url: h.moderations_articles_url,
          label: i18n_i('Article', :other)
        }
      ] + Moderation::VersionsItemTypeQuery::VERSION_TYPES
        .map do |type|
          {
            count: moderation_policy.send(:"#{type}_versions_count"),
            threshold: 0, # 10,
            url: h.moderations_versions_url(type: Moderation::VersionsItemTypeQuery::Type[type]),
            label: i18n_t(".versions.#{type}")
          }
        end
    )
      .select { |v| v[:count] > v[:threshold] }

    stats.shuffle.take(3).sort_by { |v| stats.index v }
  end

private

  def base_controller_name
    return if h.controller.class.superclass == ApplicationController
    return if h.controller.class.superclass == ShikimoriController

    h.controller.class.superclass.name.to_underscore.sub(/_controller$/, '').gsub(/::_?/, '_')
  end

  def controller_classes controller_name
    ["p-#{controller_name}", "p-#{controller_name}-#{h.action_name}"]
  end

  def ru_option? option_name
    I18n.russian? &&
      (!h.user_signed_in? || h.current_user&.preferences&.send(option_name))
  end

  def is_show_smileys? # rubocop:disable PredicateName
    h.user_signed_in? && !h.current_user.preferences.is_show_smileys?
  end

  def db_entries_controller?
    h.controller.is_a? DbEntriesController
  end

  # def ignored_users?
  #   return false unless h.user_signed_in?
  #
  #   # moderators must see posts of ignored users
  #   !h.current_user.admin? &&
  #     !h.current_user.super_moderator? &&
  #     !h.current_user.forum_moderator?
  # end

  def custom_style # rubocop:disable AbcSize
    user = h.controller.instance_variable_get(:@user)
    club = h.controller.instance_variable_get(:@club)

    if h.user_signed_in? && !h.current_user.preferences.apply_user_styles
      try_style(h.current_user)
    elsif user && !user.censored_profile? && !user.forever_banned?
      try_style(user)
    else
      try_style(club) || try_style(h.current_user)
    end
  end

  def try_style target
    target.style if target&.style&.css&.strip.present?
  end

  def moderation_policy
    ModerationPolicy.new h.current_user, true
  end
end
