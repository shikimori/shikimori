module Types::Concerns::DbEntryFields
  extend ActiveSupport::Concern

  included do |_klass|
    field :id, GraphQL::Types::ID
    field :mal_id, GraphQL::Types::ID
    field :name, String
    field :russian, String
    field :synonyms, [String]
    field :japanese, String

    field :created_at, GraphQL::Types::ISO8601DateTime
    field :updated_at, GraphQL::Types::ISO8601DateTime

    field :poster, Types::PosterType, complexity: 5

    field :url, String
    delegate :url, to: :decorated_object

  private

    def decorated_object
      @decorated_object ||= object.decorate
    end
  end
end
