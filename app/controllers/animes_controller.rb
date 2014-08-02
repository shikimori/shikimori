class AnimesController < ShikimoriController
  include ActionView::Helpers::TextHelper
  include EntriesHelper
  include ActionView::Helpers::DateHelper
  include ApplicationHelper
  include AniMangaHelper

  AutocompleteLimit = 14

  respond_to :html, only: [:show, :tooltip, :related_all]
  respond_to :json, only: :autocomplete
  respond_to :html, :json, only: :page

  before_filter :authenticate_user!, only: [:edit]

  caches_action :page, :characters, :show, :related_all, :cosplay, :tooltip,
    cache_path: proc {
      id = params[:anime_id] || params[:manga_id] || params[:id]
      @entry ||= klass.find(id.to_i)
      "#{klass.name}|#{Digest::MD5.hexdigest params.to_json}|#{@entry.updated_at.to_i}|#{@entry.thread.updated_at.to_i}|#{json?}|v3|#{request.xhr?}"
    },
    unless: proc { user_signed_in? },
    expires_in: 2.days

  # отображение аниме или манги
  def show
    @entry = klass.find(entry_id.to_i).decorate
    @itemtype = @entry.itemtype
    direct
  end

  # все связанные элементы с аниме/мангой
  def related_all
    @entry = klass.find(entry_id.to_i).decorate
    direct

    render partial: 'animes/related_all', formats: :html unless @director.redirected?
  end

  # все связанные элементы с аниме/мангой
  def other_names
    @entry ||= klass.find(params[:id].to_i)
    render partial: 'animes/other_names', formats: :html
  end

  # подстраница аниме или манги
  def page
    show
    render :show unless @director.redirected?
  end

  # редактирование аниме
  def edit
    show
    render :show unless @director.redirected?
  end

  # подстраница косплея
  def cosplay
    show
    render :show unless @director.redirected?
  end

  # торренты к эпизодам аниме
  def episode_torrents
    @entry = klass.find(params[:id].to_i).decorate
    render json: @entry.files.episodes_data
  end

  # тултип
  def tooltip
    @entry = klass.find params[:id].to_i
    direct
  end

  # автодополнение
  def autocomplete
    @items = AniMangaQuery.new(klass, params, current_user).complete
  end

  # rss лента новых серий и сабов аниме
  def rss
    anime = Anime.find(params[:id].to_i)

    case params[:type]
      when 'torrents'
        data = anime.torrents
        title = 'Торренты %s' % anime.name

      when 'torrents_480p'
        data = anime.torrents_480p
        title = 'Серии 480p %s' % anime.name

      when 'torrents_720p'
        data = anime.torrents_720p
        title = 'Серии 720p %s' % anime.name

      when 'torrents_1080p'
        data = anime.torrents_1080p
        title = 'Серии 1080p %s' % anime.name

      when 'subtitles'
        if anime.subtitles.include? params[:group]
          data = anime.subtitles[params[:group]][:feed].reverse
        else
          data = []
        end
        title = 'Субтитры %s' % anime.name
    end

    feed = RSS::Maker.make("2.0") do |feed|
      feed.channel.title = title
      feed.channel.link = request.url
      feed.channel.description = "%s, найденные сайтом." % title
      feed.items.do_sort = true # sort items by date

      data.select {|v| v[:title] }.reverse.each do |item|
        entry = feed.items.new_item

        entry.title = item[:title].html_safe
        entry.link = item[:link].html_safe
        entry.description = "Seeders: %d, Leechers: %d" % [item[:seed], item[:leech]] if item[:seed] || item[:leech]
        entry.date = item[:pubDate] != nil ? Time.at(item[:pubDate].to_i) : Time.now
      end
    end

    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    render text: feed
  end

private
  # класс текущего элемента
  def klass
    @klass ||= Object.const_get(self.class.name.underscore.split('_')[0].singularize.camelize)
  end

  def entry_id
    params[:anime_id] || params[:manga_id] || params[:id]
  end
  ## часть заголовка с названием текущего элемента
  #def entry_title
    #"#{@entry.russian_kind} #{HTMLEntities.new.decode(@entry.name)}"
  #end
end
