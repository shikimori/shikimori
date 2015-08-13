class AnimesController < DbEntryController
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

  def autocomplete
    @collection = AniMangaQuery.new(resource_klass, params, current_user).complete
  end

private

  def update_params
    params
      .require(:anime)
      .permit(:russian, :torrents_name, :tags, :description, :source, *Anime::DESYNCABLE)
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

      if params[:action] == 'edit_field' && params[:field].present?
        @back_url = @resource.edit_url
        breadcrumb i18n_t('edit'), @resource.edit_url
      end
    end
  end
end
