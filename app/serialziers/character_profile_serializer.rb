class CharacterProfileSerializer < CharacterSerializer
  attributes :altname, :japanese, :description, :description, :description_html
  attributes :favoured?, :thread_id

  has_many :seyu
  has_many :animes
  has_many :mangas

  def thread_id
    object.thread.id
  end

  def description
    if scope.ru_domain?
      object[:description_ru] || object[:description_en]
    else
      object[:description_en]
    end
  end
end
