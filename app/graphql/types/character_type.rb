class Types::CharacterType < Types::BaseObject
  field :id, ID
  field :name, String
  field :russian, String
  field :synonyms, [String]
  def synonyms
    [object.altname]
  end
  field :japanese, String

  field :url, String
  def url
    UrlGenerator.instance.character_url object
  end

  field :created_at, GraphQL::Types::ISO8601DateTime
  field :updated_at, GraphQL::Types::ISO8601DateTime

  field :description, String
  def description
    decorated_object.description.text
  end
  field :description_html, String
  def description_html
    decorated_object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end
  field :description_source, String
  def description_source
    decorated_object.description.source
  end

  field :is_anime, Boolean
  field :is_manga, Boolean
  field :is_ranobe, Boolean

  field :poster, Types::PosterType

private

  def decorated_object
    @decorated_object ||= object.decorate
  end
end
