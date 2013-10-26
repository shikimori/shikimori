class CharacterPresenter < PersonPresenter
  proxy :name, :image, :to_param, :russian, :description, :altname, :source
  proxy :cosplay_galleries, :tags, :images

  def url
    character_url person
  end

  def favoured
    @favoured ||= FavouritesQuery.new(person, 12).fetch
  end

  def favoured?
    @is_favoured ||= user_signed_in? && current_user.favoured?(person)
  end

  def seyu
    @seyu ||= person.seyu.all
  end

  def job_title
    "Персонаж #{[animes.any? ? 'аниме' : nil, mangas.any? ? 'манги' : nil].compact.join(' и ')}"
  end

  def thread
    @thread ||= person.thread
  end

  def comments
    @comments ||= person.thread.comments.with_viewed(current_user).limit(15)
  end

  def description_mal
    if person.description_mal.present?
      person.description_mal
    else
      'нет описания'
    end
  end

  # презентер косплея
  def cosplay
    @cosplay ||= AniMangaPresenter::CosplayPresenter.new entry, @view_context
  end

  # презентер пользовательских изменений
  def changes
    @changes ||= AniMangaPresenter::ChangesPresenter.new entry, @view_context
  end

  def animes
    @animes ||= ani_mangas(:animes)
  end

  def mangas
    @mangas ||= ani_mangas(:mangas)
  end

private
  def ani_mangas(kind)
    person.send(kind).all.sort_by {|v| v.aired_at || v.released_at || DateTime.new(2001) }
  end
end
