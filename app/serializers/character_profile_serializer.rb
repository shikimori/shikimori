class CharacterProfileSerializer < CharacterSerializer
  attributes :altname, :japanese, :description,
    :description, :description_html, :description_source,
    :favoured, :thread_id, :topic_id, :updated_at

  has_many :seyu
  has_many :animes, serializer: AnimeWithRoleSerializer
  has_many :mangas, serializer: MangaWithRoleSerializer

  def description
    object.description.text
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def topic_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def description
    object.description.text
  end

  def description_html
    object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end

  def description_source
    object.description.source
  end

  def favoured
    object.favoured?
  end

  def animes
    all_roles
      .select { |role| role.anime_id.present? }
      .sort_by(&:anime_id)
      .map { |role| RoleEntry.new role.anime.decorate, role.role }
  end

  def mangas
    all_roles
      .select { |role| role.manga_id.present? }
      .sort_by(&:manga_id)
      .map { |role| RoleEntry.new role.manga.decorate, role.role }
  end

private

  def all_roles
    object.person_roles.includes(:anime, :manga)
  end
end
