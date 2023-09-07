class Types::PersonType < Types::BaseObject
  include Types::Concerns::DbEntryFields

  def synonyms
    []
  end

  field :is_seyu, Boolean, null: false
  field :is_mangaka, Boolean, null: false
  field :is_producer, Boolean, null: false

  field :website, String

  field :birth_on, Types::Scalars::IncompleteDate
  field :deceased_on, Types::Scalars::IncompleteDate
end
