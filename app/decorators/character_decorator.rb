class CharacterDecorator < PersonDecorator
  def url
    h.character_url object
  end

  def source
    object.source
  end

  def favoured
    @favoured ||= FavouritesQuery.new(object, 12).fetch
  end

  def favoured?
    @is_favoured ||= h.user_signed_in? && h.current_user.favoured?(object)
  end

  def seyu
    @seyu ||= object.seyu.all
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

  def description_mal
    if object.description_mal.present?
      object.description_mal
    else
      'нет описания'
    end
  end

  # презентер косплея
  def cosplay
    @cosplay ||= AniMangaPresenter::CosplayPresenter.new object, h
  end

  # презентер пользовательских изменений
  def changes
    @changes ||= AniMangaPresenter::ChangesPresenter.new object, h
  end

  def animes
    @animes ||= ani_mangas :animes
  end

  def mangas
    @mangas ||= ani_mangas :mangas
  end

private
  def ani_mangas kind
    object.send(kind).all.sort_by {|v| v.aired_at || v.released_at || DateTime.new(2001) }
  end
end
