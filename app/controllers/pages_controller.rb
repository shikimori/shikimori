require_dependency 'traffic_entry'
require_dependency 'calendar_entry'
require_dependency 'site_statistics'

class PagesController < ShikimoriController # rubocop:disable ClassLength
  include CommentHelper
  include Sidekiq::Paginator

  respond_to :html, except: [:news]
  respond_to :rss, only: [:news]

  ONGOINGS_TOPIC_ID = 94_879
  ABOUT_TOPIC_ID = 84_739
  COPYRIGHTED_TOPIC_ID = 247_567

  def ongoings
    og page_title: i18n_t('calendar_of_ongoings')

    @ongoings_query = CalendarsQuery.new
    @topic_view =
      Topics::TopicViewFactory.new(false, false).find(ONGOINGS_TOPIC_ID)
  end

  def about
    og page_title: t('about_site')

    @statistics = SiteStatistics.new
    @topic_view =
      Topics::TopicViewFactory.new(false, false).find(ABOUT_TOPIC_ID)
  end

  def copyrighted # rubocop:disable MethodLength, AbcSize
    og page_title: t('copyrighted_animes')
    og notice: i18n_t('copyrighted_animes')

    @wakanim = Anime
      .where(id: Copyright::WAKANIM_COPYRIGHTED)
      .order(AniMangaQuery.order_sql('released_on', Anime))

    @istari = Anime
      .where(id: Copyright::ISTARI_COPYRIGHTED)
      .order(AniMangaQuery.order_sql('released_on', Anime))

    @vgtrk = Anime
      .where(id: Copyright::VGTRK_COPYRIGHTED)
      .order(AniMangaQuery.order_sql('released_on', Anime))

    @capella_film = Anime
      .where(id: Copyright::CAPELLA_FILM_COPYRIGHTED)
      .order(AniMangaQuery.order_sql('released_on', Anime))

    @exponenta = Anime
      .where(id: Copyright::EXPONENTA_COPYRIGHTED)
      .order(AniMangaQuery.order_sql('released_on', Anime))

    @pioner = Anime
      .where(id: Copyright::PIONER_COPYRIGHTED)
      .order(AniMangaQuery.order_sql('released_on', Anime))

    @other = Anime
      .where(
        id: Copyright::OTHER_COPYRIGHTED -
          Copyright::WAKANIM_COPYRIGHTED - Copyright::ISTARI_COPYRIGHTED -
          Copyright::VGTRK_COPYRIGHTED - Copyright::CAPELLA_FILM_COPYRIGHTED -
          Copyright::EXPONENTA_COPYRIGHTED - Copyright::PIONER_COPYRIGHTED
      )
      .order(AniMangaQuery.order_sql('released_on', Anime))

    @topic_view =
      Topics::TopicViewFactory.new(false, false).find(COPYRIGHTED_TOPIC_ID)
  end

  def for_right_holders
    og page_title: t('application.footer.for_right_holders')
  end

  def development
    og page_title: i18n_t('about.development')
    @blank_layout = true
  end

  def how_to_edit_achievements
    og page_title: i18n_t('.how_to_edit_achievements')
  end

  def news_feed
    @collection = Topics::Query.fetch(current_user, locale_from_host)
      .by_forum(Forum::NEWS_FORUM, current_user, censored_forbidden?)
      .limit(15)
      .as_views(true, false)
  end

  def terms
    og noindex: true
    og page_title: i18n_t('terms_of_service')
  end

  def privacy
    og noindex: true
    og page_title: i18n_t('privacy_policy')
  end

  def page404
    og page_title: t('page_not_found')
    render 'pages/page404', layout: false, status: 404, formats: :html
  end

  def page503
    og page_title: t('error')
    render 'pages/page503', layout: false, status: 503, formats: :html
  end

  def feedback
    @feedback_message = FeedbackMessage.new(
      from_id: (current_user.try(:id) || User::GUEST_ID),
      to_id: User::MORR_ID,
      kind: MessageType::PRIVATE
    )
    @feedback_message.location = request.env['HTTP_REFERER'] || request.url
  end

  def user_agent
    render plain: request.user_agent
  end

  def country
    render plain: GeoipAccess.instance.country_code(params[:ip] || remote_addr)
  end

  def raise_exception
    raise 'test'
  end

  def admin_panel # rubocop:disable all
    raise Forbidden unless user_signed_in? && current_user.admin?

    @code =
      if Rails.env.production?
        `cat REVISION`
      else
        `git rev-parse HEAD`
      end

    df = `df | head -n 2 | tail -n 1`.strip.split(/\s+/)
    disk_total = df[1].to_f
    disk_free = df[3].to_f
    @disk_space = (((disk_total - disk_free) / disk_total) * 100).round(2)

    mem = `free -m`.try :split, /\s+/

    if mem
      mem_total = mem[8].to_f
      mem_free = mem[10].to_f
      @mem_space = (((mem_total - mem_free) / mem_total) * 100).round(2)
      @mem_space = 99 if @mem_space.nan?

      # swap_total = mem[19].to_f
      # swap_free = mem[21].to_f
      # @swap_space = (((swap_total-swap_free) / swap_total)*100).round(2)
      # @swap_space = 99 if @swap_space.nan?
    end

    @calendar_update = AnimeCalendar.last.try :created_at
    @last_episodes_message = Message.where(kind: :episode).last.try :created_at
    @calendar_unrecognized = Rails.cache.read 'calendar_unrecognized'

    @proxies_count = Proxy.count

    unless Rails.env.test?
      memcached_stats = Rails.cache.stats[
        "#{Rails.application.config.cache_store[1]}:11211"
      ]
      @memcached_space = (
        memcached_stats['bytes'].to_f / memcached_stats['limit_maxbytes'].to_f * 100.0
      ).round 2
      @memcached_items = memcached_stats['curr_items'].to_i
      @memcached_hits_misses = (
        memcached_stats['get_hits'].to_f /
          (memcached_stats['get_misses'].to_f + memcached_stats['get_hits'].to_f) * 100.0
      ).round 2
      @memcached_uptime = memcached_stats['uptime'].to_i
    end

    @redis_keys = (Rails.application.redis.info['db0'] || 'keys=0')
      .split(',')[0]
      .split('=')[1]
      .to_i
    @pending_anidb = Anidb::ImportDescriptionsQuery.for_import(Anime).count
    @missing_anidb = %i[
      anons_anime_ids
      ongoing_anime_ids
      other_anime_ids
    ].flat_map { |scope| MalParsers::ScheduleExpiredAuthorized.new.send(scope) }
      .uniq
      .size

    unless Rails.env.test?
      @sidkiq_stats = Sidekiq::Stats.new
      @sidkiq_enqueued = Sidekiq::Queue
        .all
        .map { |queue| page "queue:#{queue.name}", queue.name, 100 }
        .map(&:third)
        .flatten
        .map { |v| JSON.parse v }
        .sort_by { |v| Time.at v['enqueued_at'] }

      @sidkiq_busy = Sidekiq::Workers.new
        .to_a
        .map { |v| v[2]['payload'] }
        .sort_by { |v| Time.at v['enqueued_at'] }

      @sidkiq_retries = page('retry', 'retries', 100)[2]
        .flatten
        .select { |v| v.is_a? String }
        .map { |v| JSON.parse v }
        .sort_by { |v| Time.at v['enqueued_at'] }
    end

    @animes_to_import = Anime
      .where(imported_at: nil)
      .where.not(mal_id: nil)
      .count
    @mangas_to_import = Manga
      .where(imported_at: nil)
      .where.not(mal_id: nil)
      .count
    @characters_to_import = Character
      .where(imported_at: nil)
      .where.not(mal_id: nil)
      .count
    @people_to_import = Person
      .where(imported_at: nil)
      .where.not(mal_id: nil)
      .count
  end

  def tableau
    render json: {
      messages: user_signed_in? ? current_user.unread_count : 0
    }
  end

  def bb_codes
  end

  def oauth
    if params[:oauth_application_id]
      @oauth_application = current_user
        &.oauth_applications
        &.find_by id: params[:oauth_application_id]

      if params[:authorization_code].present?
        @authorization_code = params[:authorization_code]

        render json: 'test' if params[:format] == 'json'
      end
    end
  end

  def timeout_120s
    sleep 120
    render json: 'ok'
  end

  def vue
  end

  def my_target_ad
    raise 'allowed on production only' unless Rails.env.production?
  end

  def csrf_token
    if current_user&.admin?
      render json: {
        _csrf_token: session[:_csrf_token],
        x_csrf_token: request.x_csrf_token,
        # unmasked_x_csrf_token: ((unmask_token(Base64.strict_decode64(request.x_csrf_token)) rescue ArgumentError) if request.x_csrf_token.present?), # rubocop: disable all
        is_valid: request_authenticity_tokens.any? do |token|
          valid_authenticity_token?(session, token)
        end,
        verified_request: verified_request?,
        shiki_type: ENV['SHIKI_TYPE'],
        rack_url_scheme: request['rack.url_scheme']
      }
    else
      raise CanCan::AccessDenied
    end
  end
end
