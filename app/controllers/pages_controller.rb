require_dependency 'traffic_entry'
require_dependency 'calendar_entry'
require_dependency 'site_statistics'

class PagesController < ShikimoriController
  include CommentHelper
  include Sidekiq::Paginator

  respond_to :html, except: [:news]
  respond_to :rss, only: [:news]

  ONGOINGS_TOPIC_ID = 94879
  ABOUT_TOPIC_ID = 84739

  # график онгоингов
  def ongoings
    @page_title = 'Календарь онгоингов'

    @ongoings = CalendarsQuery.new.fetch_grouped
    @topic = Topics::Factory.new(false).find ONGOINGS_TOPIC_ID
  end

  # о сайте
  def about
    @page_title = t 'about_site'
    @statistics = SiteStatistics.new
    @topic = Topics::Factory.new(false).find ABOUT_TOPIC_ID
  end

  # rss с новостями
  def news
    @topics = if params[:kind] == 'anime'
      AnimeNews
        .where.not(action: AnimeHistoryAction::Episode)
        .joins('inner join animes on animes.id=linked_id and animes.censored=false')
        .order(created_at: :desc)
        .limit(15)
        .to_a
    else
      Entry
        .where(type: Topic.name, broadcast: true)
        .order(created_at: :desc)
        .limit(10)
        .to_a
    end

    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
  end

  # пользовательское соглашение
  def user_agreement
    @page_title = 'Пользовательское соглашение'
  end

  # 404 страница
  def page404
    @page_title = "Страница не найдена"
    render 'pages/page404', layout: false, status: 404, formats: :html
  end

  # страница с ошибкой
  def page503
    @page_title = "Ошибка"
    render 'pages/page503', layout: false, status: 503, formats: :html
  end

  # страница обратной связи
  def feedback
    @feedback_message = FeedbackMessage.new(
      from_id: (current_user.try(:id) || User::GuestID),
      to_id: User::Admins.first,
      kind: MessageType::Private
    )
    @feedback_message.location = request.env['HTTP_REFERER'] || request.url
  end

  # отображение юзер-агента пользователя
  def user_agent
    render text: request.user_agent
  end

  # страница для теста эксепшенов
  def raise_exception
    raise 'test'
  end

  # информация закрытии регистрации с гугла и яндекса
  def disabled_registration
  end

  # статистика сервера
  def admin_panel
    raise Forbidden unless user_signed_in? && current_user.admin?
    df = %x{df | head -n 2 | tail -n 1}.strip.split(/\s+/)
    disk_total = df[1].to_f
    disk_free = df[3].to_f
    @disk_space = (((disk_total-disk_free) / disk_total)*100).round(2)

    mem = %x(free -m).try :split, /\s+/

    if mem
      mem_total = mem[8].to_f
      mem_free = mem[17].to_f
      @mem_space = (((mem_total-mem_free) / mem_total)*100).round(2)
      @mem_space = 99 if @mem_space.nan?

      swap_total = mem[19].to_f
      swap_free = mem[21].to_f
      @swap_space = (((swap_total-swap_free) / swap_total)*100).round(2)
      @swap_space = 99 if @swap_space.nan?
    end

    @calendar_update = AnimeCalendar.last.try :created_at
    @last_episodes_message = Message.where(kind: :episode).last.try :created_at
    @calendar_unrecognized = Rails.cache.read 'calendar_unrecognized'

    @proxies_count = Proxy.count

    unless Rails.env.test?
      memcached_stats = Rails.cache.stats['localhost:11211']
      @memcached_space = (memcached_stats['bytes'].to_f / memcached_stats['limit_maxbytes'].to_f).round 2
    end

    @redis_keys = ($redis.info['db0'] || 'keys=0').split(',')[0].split('=')[1].to_i

    unless Rails.env.test?
      @sidkiq_stats = Sidekiq::Stats.new
      @sidkiq_enqueued = Sidekiq::Queue
        .all
        .map { |queue| page "queue:#{queue.name}", queue.name, 100 }
        .map { |data| data.third }
        .flatten
        .map { |v| JSON.parse v }
        .sort_by { |v| Time.at v['enqueued_at'] }

      @sidkiq_busy = Sidekiq::Workers.new.to_a.map {|v| v[2]['payload'] }.sort_by {|v| Time.at v['enqueued_at'] }

      @sidkiq_retries = page('retry', 'retries', 100)[2]
        .flatten
        .select {|v| v.kind_of? String }
        .map {|v| JSON.parse v }
        .sort_by {|v| Time.at v['enqueued_at'] }
    end

    @animes_to_import = Anime.where(imported_at: nil).count
    @mangas_to_import = Manga.where(imported_at: nil).count
    @characters_to_import = Character.where(imported_at: nil).count
    @people_to_import = Person.where(imported_at: nil).count
  end

  def tableau
    render json: {
      messages: user_signed_in? ? current_user.unread_count : 0
    }
  end

  def bb_codes
  end

  def timeout_120s
    sleep 120
    render json: 'ok'
  end
end
