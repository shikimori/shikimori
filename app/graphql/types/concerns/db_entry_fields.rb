module Types::Concerns::DbEntryFields
  extend ActiveSupport::Concern

  included do |_klass|
    field :id, GraphQL::Types::ID, null: false
    field :mal_id, GraphQL::Types::ID
    field :name, String, null: false
    field :russian, String
    field :synonyms, [String], null: false
    field :japanese, String

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :poster, Types::PosterType, complexity: 5

    field :url, String, null: false
    delegate :url, to: :decorated_object

  private

    def decorated_object
      @decorated_object ||= object.decorate
    end
  end
end
