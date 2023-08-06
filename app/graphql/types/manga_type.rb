class Types::MangaType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::DescriptionFields

  field :license_name_ru, String
  field :english, String
  field :franchise, String, description: 'Franchise name'
  field :kind, Types::Enums::Manga::KindEnum
  field :score, Float
  field :status, Types::Enums::StatusEnum
  field :volumes, Integer
  field :chapters, Integer

  field :aired_on, Types::Scalars::IncompleteDate
  field :released_on, Types::Scalars::IncompleteDate

  field :licensors, [String]

  field :is_censored, Boolean
  def is_censored # rubocop:disable Naming/PredicateName
    object.censored?
  end

  field :genres, [Types::GenreType]
  field :publishers, [Types::PublisherType]

  field :user_rate, Types::UserRateType, complexity: 50
  def user_rate
    decorated_object.current_rate
  end
end
