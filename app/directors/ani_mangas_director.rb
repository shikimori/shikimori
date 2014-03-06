class AniMangasDirector < BaseDirector
  include UsersHelper

  page :info
  page :stats, -> { entry.with_stats? }
  page :recent, -> { entry.with_stats? }
  page :characters, -> { entry.roles.any? }
  page :similar, -> { entry.related.similar.any? }
  page :chronology, -> { entry.related.any? }
  page lambda { ['cosplay', ['all'] + entry.cosplay.characters.map(&:to_param) ] }, -> { entry.cosplay.characters.any? }
  page :screenshots, -> { entry.anime? && entry.screenshots.any? && entry.display_sensitive? }
  page :videos, -> { entry.anime? && entry.videos.any? }
  page :images, -> { entry.tags.present? || entry.images.any? }
  page :files, -> { entry.anime? && !entry.anons? && entry.display_sensitive? }

  page [:reviews, [:index]]
  page [:reviews, [:edit]]

  page [:edit, [:description]], -> { user_signed_in? }
  page [:edit, [:russian]], -> { user_signed_in? }
  page [:edit, [:screenshot]], -> { user_signed_in? && entry.anime? }
  page [:edit, [:videos]], -> { user_signed_in? && entry.anime? }
  page [:edit, [:torrents_name]], -> { user_signed_in? && entry.anime? }

  def show
    append_title! HTMLEntities.new.decode(entry.russian) if entry.russian.present?
    append_title! entry.name

    noindex if entry.object[:description].blank? || entry.kind == 'Special'

    description entry.seo_description
    keywords entry.seo_keywords

    redirect!
  end

  def edit
    noindex && nofollow
    case params[:subpage].to_sym
      when :russian
        append_title! 'Изменение русского названия'

      when :description
        append_title! 'Изменение описания'

      when :videos
        append_title! 'Изменение видео'

      when :torrents_name
        append_title! 'Изменение названия на торрентах'

      when :screenshot
        append_title! 'Изменение кадров'

      else
        raise ArgumentError.new "page: #{params[:page]}"
    end
  end

  def page
    show

    noindex
    case params[:page].to_sym
      when :similar
        append_title! entry.anime? ? 'Похожие аниме' : 'Похожая манга'

      when :recent
        append_title! 'Последняя активность'

      when :stats
        append_title! 'Статистика'

      when :stats
        append_title! 'Последняя активность'

      when :screenshots
        append_title! 'Кадры'

      when :videos
        append_title! 'Видео'

      when :files
        append_title! 'Файлы'

      when :characters
        append_title! 'Персонажи и создатели'

      when :images
        append_title! 'Галерея'

      when :chronology
        append_title! 'Хронология'

      else
        raise ArgumentError.new "page: #{params[:page]}"
    end
  end

  def cosplay
    params[:subpage] = params[:character]
    show

    unless entry.cosplay.gallery || @redirected
      redirect_to entry.cosplay_url :all
      @redirected = true
      return
    end

    append_title! entry.cosplay.gallery.full_title(entry) unless redirected?
  end

  def tooltip
    noindex && nofollow
    redirect! entry.class == Anime ? tooltip_anime_url(entry) : tooltip_manga_url(entry)
  end

  def related_all
    redirect!
  end

  # переопределяем построение партиала для косплея
  def partial
    if params[:page] == 'cosplay'
      view_root + '/cosplay'
    else
      super
    end
  end

private
  def build_crumbs
    if entry.anime?
      append_crumb! 'Список аниме', animes_url
      append_crumb! 'Сериалы', animes_url(type: entry.kind) if entry.kind == 'TV'
      append_crumb! 'Полнометражные', animes_url(type: entry.kind) if entry.kind == 'Movie'
    else
      append_crumb! 'Список манги', mangas_url
    end

    if entry.aired_on && [DateTime.now.year + 1, DateTime.now.year, DateTime.now.year - 1].include?(entry.aired_on.year)
      append_crumb! "#{entry.aired_on.year} год", send("#{entry.object.class.name.downcase.pluralize}_url", season: entry.aired_on.year)
    end

    if entry.genres.any?
      append_crumb! localized_name(entry.main_genre), send("#{entry.object.class.name.downcase.pluralize}_url", genre: entry.main_genre.to_param)
    end
  end

  def redirect?
    entry.to_param != entry_id || params[:character] == '&'
  end

  def redirect_url
    url_for params.merge('id' => entry.to_param).except('subpage')
  end

  def view_root
    'ani_mangas'
  end
end
