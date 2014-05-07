require_dependency 'traffic_entry'
require_dependency 'ongoing_entry'
require_dependency 'site_statistics'

class PagesController < ApplicationController
  include CommentHelper
  include Sidekiq::Paginator

  layout false, only: [:auth_form, :feedback, :admin_panel]
  respond_to :html, except: [:news]
  respond_to :ress, only: [:news]

  # блок авторизации/регистрации
  def auth_form
  end

  # график онгоингов
  def calendar
    @page_title = 'Календарь онгоингов'

    @query = OngoingsQuery.new
    @topic = TopicPresenter.new(
      object: Topic.find(94879),
      template: view_context,
      limit: 5,
      with_user: true
    )
  end

  # о сайте
  def about
    @page_title = 'О сайте'
    @statistics = SiteStatistics.new

    @topic = TopicPresenter.new(
      object: Topic.find(84739),
      template: view_context,
      limit: 5,
      with_user: true
    )
  end

  # rss с новостями
  def news
    @topics = if params[:kind] == 'anime'
      AnimeNews.where.not(action: AnimeHistoryAction::Episode)
          .joins('inner join animes on animes.id=linked_id and animes.censored=false')
          .order(created_at: :desc)
          .limit(15)
          .to_a
    else
      Entry.where(type: Topic.name, broadcast: true)
          .order(created_at: :desc)
          .limit(10)
          .to_a
    end

    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
  end

  # пользовательское соглашение
  def user_agreement
    @sitename = 'shikimori.org'
    @page_title = 'Пользовательское соглашение'
  end

  # 404 страница
  def page404
    @page_title = "Страница не найдена"
    render 'pages/page404', layout: 'application', status: 404, formats: :html
  end

  # страница с ошибкой
  def page503
    @page_title = "Ошибка"
    render 'pages/page503', layout: 'application', status: 503, formats: :html
  end

  # страница обратной связи
  def feedback
  end

  # отображение юзер-агента пользователя
  def user_agent
    render text: request.user_agent
  end

  # тестовая страница
  def test
    @traffic = Rails.cache.fetch("traffic_#{Date.today}") { YandexMetrika.new.traffic_for_months 18 }
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

      swap_total = mem[19].to_f
      swap_free = mem[21].to_f
      @swap_space = (((swap_total-swap_free) / swap_total)*100).round(2)
    end

    @calendar_update = AnimeCalendar.last.try :created_at
    @last_episodes_message = Message.where(kind: :episode).last.created_at
    @calendar_unrecognized = Rails.cache.read 'calendar_unrecognized'

    @proxies_count = Proxy.count

    socket = TCPSocket.open 'localhost', '11211'
    socket.send "stats\r\n", 0

    statistics = []
    loop do
      data = socket.recv(4096)
      if !data || data.length == 0
        break
      end
      statistics << data
      if statistics.join.split(/\n/)[-1] =~ /END/
        break
      end
    end
    stat = statistics.join.split("\r\n").select {|v| v =~ /STAT (?:bytes|limit_maxbytes) / }.map {|v| v.match(/\d+/)[0].to_f }
    @memcached_space = ((1 - (stat[0]-stat[1]) / stat[0])*100).round(2)

    @redis_keys = ($redis.info['db0'] || 'keys=0').split(',')[0].split('=')[1].to_i

    @sidkiq_stats = Sidekiq::Stats.new
    @sidkiq_enqueued = Sidekiq::Queue
      .all
      .map {|queue| page "queue:#{queue.name}", queue.name, 100 }
      .map {|data| data.third }
      .flatten
      .map {|v| JSON.parse v }
      .sort_by {|v| Time.at v['enqueued_at'] }

    @sidkiq_busy = Sidekiq.redis do |conn|
      conn.smembers('workers').map do |w|
        msg = conn.get("worker:#{w}")
        msg ? [w, Sidekiq.load_json(msg)] : (to_rem << w; nil)
      end.compact.sort { |x| x[1] ? -1 : 1 }
    end.map {|v| v.second['payload'] }.sort_by {|v| Time.at v['enqueued_at'] }

    @sidkiq_retries = page('retry', 'retries', 100)[2]
      .flatten
      .select {|v| v.kind_of? String }
      .map {|v| JSON.parse v }
      .sort_by {|v| Time.at v['enqueued_at'] }

    @animes_to_import = Anime.where(imported_at: nil).count
    @mangas_to_import = Manga.where(imported_at: nil).count
    @characters_to_import = Character.where(imported_at: nil).count
    @people_to_import = Person.where(imported_at: nil).count
  end

  def welcome_gallery
    @gallery = WellcomeGalleryPresenter.new
    render partial: 'forum/gallery', formats: :html
  end

  def tableau
    render json: {
      messages: user_signed_in? ? current_user.unread_count : 0
    }
  end
end
