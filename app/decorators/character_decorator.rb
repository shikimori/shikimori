class CharacterDecorator < PersonDecorator
  instance_cache :seyu, :changes, :all_animes, :all_mangas, :cosplay?
  instance_cache :limited_animes, :limited_mangas

  def url
    h.character_url object
  end

  def seyu
    object.seyu.uniq.to_a
  end

  def job_title
    i18n_t "job_title.#{animes.any? ? 'anime_': nil}#{mangas.any? ? 'manga_' : nil}character"
  end

  # презентер косплея
  def cosplay
    @cosplay ||= AniMangaPresenter::CosplayPresenter.new object, h
  end

  # презентер пользовательских изменений
  def changes
    AniMangaDecorator::ChangesDecorator.new object
  end

  def animes limit = nil
    decorated_entries object.animes.limit(limit)
  end

  def mangas limit = nil
    decorated_entries object.mangas.limit(limit)
  end

  # есть ли косплей
  def cosplay?
    CosplayGalleriesQuery.new(object).fetch(1,1).any?
  end

private

  def decorated_entries query
    query
      .decorate
      .sort_by {|v| v.aired_on || v.released_on || DateTime.new(2001) }
  end
end
