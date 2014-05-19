class UserListQuery
  def initialize klass, user, current_user, params
    @klass = klass
    @user = user
    @current_user = current_user

    @params = params.clone.merge(klass: @klass)
    @params.delete(:order)
  end

  def fetch
    rate_ds = @user.send("#{list_type}_rates")
    rate_ds = rate_ds.where(status: UserRateStatus.get(@params[:list_type_kind])) if @params[:list_type_kind]
    rate_ids = rate_ds.select('distinct(target_id)').map(&:target_id)

    entries = fetch_entries
    rates = fetch_rates entries

    list = rates.each_with_object({}) do |v,memo|
      target = entries[v.target_id]

      memo[v.status] = [] unless memo.include?(v.status)
      memo[v.status] << {
        id: target.id,
        name: view_context.localized_name(target),
        kind: target.kind,
        kind_localized: target.kind.blank? ? '' : view_context.localized_kind(target, true),
        status_localized: target.status.present? ? I18n.t("AniMangaStatusUpper.#{target.status}") : '',
        url: "/#{params[:list_type]}s/#{v.target_id}",

        rate_id: v.id,
        rate_text: v.text_html,
        rate_episodes: anime? ? v.episodes : nil,
        rate_volumes: anime? ? nil : v.volumes,
        rate_chapters: anime? ? nil : v.chapters,
        rate_score: v.score && v.score != 0 ? v.score : '&ndash;',

        ongoing?: target.ongoing?,
        anons?: target.anons?,

        episodes: anime? ? (target.episodes.zero? ? nil : target.episodes) : nil,
        episodes_aired: anime? ? target.episodes_aired : nil,
        chapters: anime? ? nil : (target.chapters.zero? ? nil : target.chapters),
        volumes: anime? ? nil : (target.volumes.zero? ? nil: target.volumes),
        duration: anime? ? target.duration : Manga::Duration,
      }
    end
  end

private
  def fetch_entries
    AniMangaQuery.new(@klass, @params, @user)
      .fetch
      .where(id: rate_ids)
      .select("
        #{entry_table_name}.id,
        #{entry_table_name}.kind,
        #{entry_table_name}.name,
        #{entry_table_name}.russian,
        #{entry_table_name}.aired_on,
        #{entry_table_name}.released_on,

        #{anime? ? "#{entry_table_name}.episodes_aired as episodes_aired," : ''}
        #{anime? ? "#{entry_table_name}.episodes as episodes," : ''}
        #{anime? ? "#{entry_table_name}.duration," : ''}

        #{anime? ? '' : "#{entry_table_name}.volumes as volumes,"}
        #{anime? ? '' : "#{entry_table_name}.chapters as chapters,"}

        #{list_type.tableize}.status
      ")
      .all
      .each_with_object({}) { |entry, memo| memo[entry.id] = entry }
  end

  def fetch_rates entries
    @user.send("#{list_type}_rates")
      .where(target_id: entries.keys)
      .joins(list_type.to_sym)
      .order("user_rates.status, #{AniMangaQuery.order_sql(order, @klass)}")
      .all
  end

  def entry_table_name
    list_type.tableize
  end

  def list_type
    @params[:list_type]
  end

  def order
    @params[:order]
  end

  def anime?
    list_type == 'anime'
  end
end
