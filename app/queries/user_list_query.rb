class UserListQuery
  def initialize klass, user, params
    @klass = klass
    @user = user

    @params = params.clone.merge(klass: @klass)
  end

  def fetch
    user_rates
      .merge(AniMangaQuery.new(@klass, @params, @user).fetch.except(:order))
      .order("user_rates.status, #{AniMangaQuery.order_sql order, @klass}")
      .each_with_object({}) do |v,memo|
        memo[v.status.to_sym] ||= []
        memo[v.status.to_sym] << v.decorate
      end

      #memo[v.status] << {
        #id: target.id,
        #name: view_context.localized_name(target),
        #kind: target.kind,
        #kind_localized: target.kind.blank? ? '' : view_context.localized_kind(target, true),
        #status_localized: target.status.present? ? I18n.t("AniMangaStatusUpper.#{target.status}") : '',
        #url: "/#{params[:list_type]}s/#{v.target_id}",

        #rate_id: v.id,
        #rate_text: v.text_html,
        #rate_episodes: anime? ? v.episodes : nil,
        #rate_volumes: anime? ? nil : v.volumes,
        #rate_chapters: anime? ? nil : v.chapters,
        #rate_score: v.score && v.score != 0 ? v.score : '&ndash;',

        #ongoing?: target.ongoing?,
        #anons?: target.anons?,

        #episodes: anime? ? (target.episodes.zero? ? nil : target.episodes) : nil,
        #episodes_aired: anime? ? target.episodes_aired : nil,
        #chapters: anime? ? nil : (target.chapters.zero? ? nil : target.chapters),
        #volumes: anime? ? nil : (target.volumes.zero? ? nil: target.volumes),
        #duration: anime? ? target.duration : Manga::Duration,
      #}
  end

private
  def user_rates
    @user.send("#{list_type}_rates")
      .includes(list_type.to_sym)
      .references(list_type.to_sym)
  end

  def list_type
    @klass.name.downcase
  end

  def order
    @params[:order]
  end

  def anime?
    list_type == 'anime'
  end
end
