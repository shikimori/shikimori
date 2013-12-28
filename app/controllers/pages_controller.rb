require_dependency 'traffic_entry'

class PagesController < ApplicationController
  include CommentHelper

  layout false, only: [:auth_form, :feedback, :admin_panel]
  respond_to :html, except: [:news]
  respond_to :ress, only: [:news]


  # блок авторизации/регистрации
  def auth_form
  end

  # график онгоингов
  def calendar
    @page_title = 'Календарь онгоингов'

    data = Rails.cache.fetch('calendar_' + WellcomeNewsPresenter.cache_key, expires_in: 3.hours) do
      OngoingsQuery.new.prefetch
    end
    @ongoings = OngoingsQuery.new.process data, current_user, true

    @topic = TopicPresenter.new object: Topic.find(94879), template: view_context, limit: 1000, with_user: true
  end

  # rss с новостями
  def news
    @topics = if params[:kind] == 'anime'
      AnimeNews.where { action.not_eq(AnimeHistoryAction::Episode) }
          .joins('inner join animes on animes.id=linked_id and animes.censored=false')
          .order { created_at.desc }
          .limit(15)
          .all
    else
      Entry.where(type: Topic.name, broadcast: true)
          .order { created_at.desc }
          .limit(10)
          .all
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

    mem = %x(free -m).split(/\s+/)

    mem_total = mem[8].to_f
    mem_free = mem[17].to_f
    @mem_space = (((mem_total-mem_free) / mem_total)*100).round(2)

    swap_total = mem[19].to_f
    swap_free = mem[21].to_f
    @swap_space = (((swap_total-swap_free) / swap_total)*100).round(2)

    @job_workers = %x{ps aux | grep delayed_jo}.split("morr").select {|v| v =~ /delayed_job/ }.size

    @jobs_queue = Delayed::Job.order(:run_at)

    @calendar_update = AnimeCalendar.last.try :created_at
    @calendar_unrecognized = Rails.cache.read 'calendar_unrecognized'

    @proxies_count = Proxy.count

    socket = TCPSocket.open('localhost', '11211')
    socket.send("stats\r\n", 0)

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

    @redis_keys = $redis.info['db0'].split(',')[0].split('=')[1]

    @animes_to_import = Anime.where(imported_at: nil).count
    @mangas_to_import = Manga.where(imported_at: nil).count
    @characters_to_import = Character.where(imported_at: nil).count
    @people_to_import = Person.where(imported_at: nil).count
  end

  # о сайте
  def about
    @page_title = 'О сайте'
    @statistics = SiteStatistics.new
    @topic = TopicPresenter.new object: Topic.find(84739), template: view_context, limit: 1000, with_user: true
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
