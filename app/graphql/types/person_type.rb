class Types::PersonType < Types::BaseObject
  include Types::Concerns::DbEntryFields

  def synonyms
    []
  end

  field :is_seyu, Boolean
  field :is_mangaka, Boolean
  field :is_producer, Boolean

  field :website, String

  field :birth_on, Types::Scalars::IncompleteDate
  field :deceased_on, Types::Scalars::IncompleteDate
end
