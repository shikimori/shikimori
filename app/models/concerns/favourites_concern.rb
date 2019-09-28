module FavouritesConcern
  extend ActiveSupport::Concern

  included do
    has_many :favourites,
      ->(entry) { where linked_type: entry.class.name },
      foreign_key: :linked_id,
      dependent: :destroy
  end
end
