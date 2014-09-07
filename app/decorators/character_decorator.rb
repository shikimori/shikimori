class CharacterDecorator < PersonDecorator
  instance_cache :favoured, :favoured?, :seyu, :changes, :all_animes, :all_mangas, :limited_animes, :limited_mangas

  def url
    h.character_url object
  end

  def favoured
    FavouritesQuery.new.favoured_by object, 12
  end

  def favoured?
    h.user_signed_in? && h.current_user.favoured?(object)
  end

  def seyu
    object.seyu.to_a
  end

  def job_title
    "Персонаж #{[animes.any? ? 'аниме' : nil, mangas.any? ? 'манги' : nil].compact.join(' и ')}"
  end

  def thread
    @thread ||= object.thread
  end

  def comments
    @comments ||= object.thread.comments.with_viewed(h.current_user).limit(15)
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

  # основной топик
  def thread
    thread = TopicDecorator.new object.thread
    thread.preview_mode!
    thread
  end

private
  def decorated_entries query
    query
      .decorate
      .sort_by {|v| v.aired_on || v.released_on || DateTime.new(2001) }
  end
end
