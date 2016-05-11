class AnimesController < DbEntriesController
  before_action -> { page_title resource_klass.model_name.human }

  before_action :set_breadcrumbs, if: -> { @resource }
  before_action :resource_redirect, if: -> { @resource }

  # временно отключаю, всё равно пока не тормозит
  #caches_action :page, :characters, :show, :related, :cosplay, :tooltip,
    #cache_path: proc {
      #id = params[:anime_id] || params[:manga_id] || params[:id]
      #@resource ||= klass.find(id.to_i)
      #"#{klass.name}|#{Digest::MD5.hexdigest params.to_json}|#{@resource.updated_at.to_i}|#{@resource.topic.updated_at.to_i}|#{json?}|v3|#{request.xhr?}"
    #},
    #unless: proc { user_signed_in? },
    #expires_in: 2.days

  # display anime or manga
  def show
    @itemtype = @resource.itemtype
  end

  def characters
    if @resource.roles.main_characters.none? && @resource.roles.supporting_characters.none?
      return redirect_to @resource.url, status: 301
    end

    noindex
    page_title i18n_t("characters.#{@resource.object.class.name.downcase}")
  end

  def staff
    return redirect_to @resource.url, status: 301 if @resource.roles.people.none?

    noindex
    page_title i18n_t("producers.#{@resource.object.class.name.downcase}")
  end

  def files
    return redirect_to @resource.url, status: 301 unless user_signed_in? && ignore_copyright?

    noindex
    page_title i18n_t 'files'
  end

  def similar
    return redirect_to @resource.url, status: 301 if @resource.related.similar.none?

    noindex
    page_title i18n_t("similar.#{@resource.object.class.name.downcase}")
  end

  def screenshots
    unless @resource.screenshots.any? && user_signed_in? && ignore_copyright?
      return redirect_to @resource.url, status: 301
    end

    noindex
    page_title i18n_i('screenshot', :other).capitalize
  end

  def videos
    unless @resource.videos.any? && user_signed_in? && ignore_copyright?
      return redirect_to @resource.url, status: 301
    end

    noindex
    page_title i18n_i('video').capitalize
  end

  def related
    return redirect_to @resource.url, status: 301 unless @resource.related.any?

    noindex
    page_title i18n_t("related.#{@resource.object.class.name.downcase}")
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

  def summaries
    return redirect_to @resource.url, status: 301 unless @resource.topic.any_summaries?

    page_title i18n_t("reviews.#{@resource.object.class.name.downcase}")
    #@canonical = UrlGenerator.instance.topic_url(@resource.topic)
  end

  def art
    noindex
    page_title t('imageboard_art')
  end

  def images
    return redirect_to @resource.art_url, status: 301
  end

  def cosplay
    @page = [params[:page].to_i, 1].max
    @limit = 2
    @collection, @add_postloader = CosplayGalleriesQuery.new(@resource.object).postload @page, @limit

    return redirect_to @resource.url, status: 301 if @collection.none?

    page_title t('cosplay')
  end

  def favoured
    return redirect_to @resource.url, status: 301 if @resource.all_favoured.none?

    noindex
    page_title t('in_favourites')
  end

  def clubs
    if @resource.all_linked_clubs.none?
      return redirect_to @resource.url, status: 301
    end

    noindex
    page_title i18n_i('Club', :other)
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
      .permit(
        :russian, :torrents_name, :tags, :source,
        :description_ru, :description_en,
        *Anime::DESYNCABLE
      )
  rescue ActionController::ParameterMissing
    {}
  end

  def set_breadcrumbs
    if @resource.anime?
      breadcrumb i18n_t('breadcrumbs.anime.list'), animes_url

      if @resource.kind_tv?
        breadcrumb i18n_t('breadcrumbs.anime.tv'),
          animes_url(type: @resource.kind)
      end

      if @resource.kind_movie?
        breadcrumb i18n_t('breadcrumbs.anime.movie'),
          animes_url(type: @resource.kind)
      end
    else
      breadcrumb i18n_t('breadcrumbs.manga.list'), mangas_url
    end

    if @resource.aired_on &&
        [Time.zone.now.year + 1, Time.zone.now.year, Time.zone.now.year - 1].include?(@resource.aired_on.year)

      season_text = Titles::LocalizedSeasonText.new(
        @resource.object.class,
        @resource.aired_on.year.to_s
      ).title
      url = send(
        "#{@resource.object.class.name.downcase.pluralize}_url",
        season: @resource.aired_on.year
      )

      breadcrumb season_text, url
    end

    if @resource.genres.any?
      breadcrumb UsersHelper.localized_name(@resource.main_genre, current_user),
        send("#{@resource.object.class.name.downcase.pluralize}_url", genre: @resource.main_genre.to_param)
    end

    if @resource
      # все страницы, кроме animes#show
      if (params[:action] != 'show' || params[:controller] == 'reviews')
        breadcrumb UsersHelper.localized_name(@resource, current_user), @resource.url(false)
      end

      if params[:action] == 'edit_field' && params[:field].present?
        @back_url = @resource.edit_url
        breadcrumb i18n_t('edit'), @resource.edit_url
      end
    end
  end
end
