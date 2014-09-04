class CharacterDecorator < PersonDecorator
  def url
    h.character_url object
  end

  def favoured
    @favoured ||= FavouritesQuery.new.favoured_by object, 12
  end

  def favoured?
    @is_favoured ||= h.user_signed_in? && h.current_user.favoured?(object)
  end

  def seyu
    @seyu ||= object.seyu.to_a
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
    @changes ||= AniMangaDecorator::ChangesDecorator.new object
  end

  def animes
    @animes ||= ani_mangas :animes
  end

  def mangas
    @mangas ||= ani_mangas :mangas
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/Person'
  end

private
  def ani_mangas kind
    object.send(kind).sort_by {|v| v.aired_on || v.released_on || DateTime.new(2001) }
  end
end
