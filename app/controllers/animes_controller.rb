class AnimesController < ShikimoriController
  before_action :authenticate_user!, only: [:edit]
  before_action -> { page_title resource_klass.model_name.human }
  before_action :fetch_resource, if: :resource_id
  before_action :set_breadcrumbs, if: -> { @resource }
  before_action :resource_redirect, if: -> { @resource }

  # временно отключаю, всё равно пока не тормозит
  #caches_action :page, :characters, :show, :related, :cosplay, :tooltip,
    #cache_path: proc {
      #id = params[:anime_id] || params[:manga_id] || params[:id]
      #@resource ||= klass.find(id.to_i)
      #"#{klass.name}|#{Digest::MD5.hexdigest params.to_json}|#{@resource.updated_at.to_i}|#{@resource.thread.updated_at.to_i}|#{json?}|v3|#{request.xhr?}"
    #},
    #unless: proc { user_signed_in? },
    #expires_in: 2.days

  # отображение аниме или манги
  def show
    @itemtype = @resource.itemtype
  end

  def characters
    if @resource.roles.main_characters.none? && @resource.roles.supporting_characters.none?
      return redirect_to @resource.url, status: 301
    end

    noindex
    page_title "Персонажи #{@resource.anime? ? 'аниме' : 'манги'}"
  end

  def staff
    return redirect_to @resource.url, status: 301 if @resource.roles.people.none?

    noindex
    page_title "Создатели #{@resource.anime? ? 'аниме' : 'манги'}"
  end

  def files
    return redirect_to @resource.url, status: 301 unless user_signed_in? && ignore_copyright?

    noindex
    page_title 'Файлы'
  end

  def similar
    return redirect_to @resource.url, status: 301 if @resource.related.similar.none?

    noindex
    page_title(@resource.anime? ? 'Похожие аниме' : 'Похожая манга')
  end

  def screenshots
    return redirect_to @resource.url, status: 301 if @resource.screenshots.none?

    noindex
    page_title 'Кадры'
  end

  def videos
    return redirect_to @resource.url, status: 301 if @resource.videos.none?

    noindex
    page_title 'Видео'
  end

  def related
    return redirect_to @resource.url, status: 301 unless @resource.related.any?

    noindex
    page_title(@resource.anime? ? 'Связанное с аниме' : 'Связанное с мангой')
  end

  def chronology
    return redirect_to @resource.url, status: 301 unless @resource.related.chronology?

    noindex
    page_title t('animes.page.chronology')
  end

  def franchise
    return redirect_to @resource.url, status: 301 unless @resource.related.chronology?

    noindex
    page_title t('animes.page.franchise')
    @blank_layout = true
  end

  #def recent
    #1/0
  #end

  # TODO: удалить после 05.2015
  def comments
    return redirect_to UrlGenerator.instance.topic_url(@resource.thread), status: 301
  end

  def reviews
    return redirect_to @resource.url, status: 301 if @resource.comment_reviews_count.zero?
    page_title "Отзывы #{@resource.anime? ? 'об аниме' : 'о манге'}"
    #@canonical = UrlGenerator.instance.topic_url(@resource.thread)
  end

  def art
    noindex
    page_title 'Арт с имиджборд'
  end

  def images
    return redirect_to @resource.art_url, status: 301
  end

  def cosplay
    @page = [params[:page].to_i, 1].max
    @limit = 2
    @collection, @add_postloader = CosplayGalleriesQuery.new(@resource.object).postload @page, @limit

    return redirect_to @resource.url, status: 301 if @collection.none?

    page_title 'Косплей'
  end

  def favoured
    return redirect_to @resource.url, status: 301 if @resource.all_favoured.none?

    noindex
    page_title 'В избранном'
  end

  def clubs
    return redirect_to @resource.url, status: 301 if @resource.all_linked_clubs.none?

    noindex
    page_title 'Клубы'
  end

  def resources
    render partial: 'resources'
  end

  def other_names
    noindex
  end

  # торренты к эпизодам аниме
  def episode_torrents
    render json: @resource.files.episodes_data
  end

  def edit
    noindex
    page_title i18n_t('entry_edit')

    @page = params[:page]

    # TODO: удалить после выпиливания UserChange
    @user_change = UserChange.new(
      model: @resource.object.class.name,
      item_id: @resource.id,
      column: @page,
      source: @resource.source,
      value: @resource[@page],
      action: params[:page] == 'screenshots' ? UserChange::ScreenshotsPosition : nil
    )
  end

  # список изменений аниме
  def versions
  end

  def tooltip
  end

  def autocomplete
    @collection = AniMangaQuery.new(resource_klass, params, current_user).complete
  end

  def update
    version = Versioneer.new(@resource.object).premoderate(anime_params, current_user, params[:reason])

    if version.persisted? && can?(:manage, version)
      version.accept current_user if params[:apply]
      version.take current_user if params[:take]
    end

    redirect_to_back_or_to @resource.url, notice: i18n_t("changes_#{version.state}")
  end

  # rss лента новых серий и сабов аниме
  #def rss
    #anime = Anime.find(params[:id].to_i)

    #case params[:type]
      #when 'torrents'
        #data = anime.torrents
        #title = "Торренты #{anime.name}"

      #when 'torrents_480p'
        #data = anime.torrents_480p
        #title = "Серии 480p #{anime.name}"

      #when 'torrents_720p'
        #data = anime.torrents_720p
        #title = "Серии 720p #{anime.name}"

      #when 'torrents_1080p'
        #data = anime.torrents_1080p
        #title = "Серии 1080p #{anime.name}"

      #when 'subtitles'
        #if anime.subtitles.include? params[:group]
          #data = anime.subtitles[params[:group]][:feed].reverse
        #else
          #data = []
        #end
        #title = "Субтитры #{anime.name}"
    #end

    #feed = RSS::Maker.make("2.0") do |feed|
      #feed.channel.title = title
      #feed.channel.link = request.url
      #feed.channel.description = "%s, найденные сайтом." % title
      #feed.items.do_sort = true # sort items by date

      #data.select {|v| v[:title] }.reverse.each do |item|
        #entry = feed.items.new_item

        #entry.title = item[:title].html_safe
        #entry.link = item[:link].html_safe
        #entry.description = "Seeders: %d, Leechers: %d" % [item[:seed], item[:leech]] if item[:seed] || item[:leech]
        #entry.date = item[:pubDate] != nil ? Time.at(item[:pubDate].to_i) : Time.now
      #end
    #end

    #response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    #render text: feed
  #end

private

  def anime_params
    params
      .require(:anime)
      .permit(:russian, :torrents_name, :tags, :description, :source, *Anime::DESYNCABLE)
  end

  def manga_params
    params
      .require(:manga)
      .permit(:russian, :tags, :description, :source, *Manga::DESYNCABLE)
  end

  def set_breadcrumbs
    if @resource.anime?
      breadcrumb 'Список аниме', animes_url
      breadcrumb 'Сериалы', animes_url(type: @resource.kind) if @resource.anime? && @resource.tv?
      breadcrumb 'Полнометражные', animes_url(type: @resource.kind) if @resource.anime? && @resource.movie?
    else
      breadcrumb 'Список манги', mangas_url
    end

    if @resource.aired_on && [Time.zone.now.year + 1, Time.zone.now.year, Time.zone.now.year - 1].include?(@resource.aired_on.year)
      breadcrumb "#{@resource.aired_on.year} год", send("#{@resource.object.class.name.downcase.pluralize}_url", season: @resource.aired_on.year)
    end

    if @resource.genres.any?
      breadcrumb UsersHelper.localized_name(@resource.main_genre, current_user), send("#{@resource.object.class.name.downcase.pluralize}_url", genre: @resource.main_genre.to_param)
    end

    if @resource
      # все страницы, кроме animes#show
      if (params[:action] != 'show' || params[:controller] == 'reviews')
        breadcrumb UsersHelper.localized_name(@resource, current_user), @resource.url
      end

      if params[:action] == 'edit' && params[:page].present?
        @back_url = @resource.edit_url
        breadcrumb i18n_t('edit'), @resource.edit_url
      end
    end
  end
end
