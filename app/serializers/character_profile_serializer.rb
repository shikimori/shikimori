class CharacterProfileSerializer < CharacterSerializer
  attributes :altname, :japanese, :description,
    :description, :description_html, :description_source,
    :favoured?, :thread_id, :topic_id, :updated_at

  has_many :seyu
  has_many :animes
  has_many :mangas

  # TODO: deprecated
  def thread_id
    object.maybe_topic(scope.locale_from_domain).id
  end

  def topic_id
    object.maybe_topic(scope.locale_from_domain).id
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
end
