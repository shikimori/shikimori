module CollectionsConcern
  extend ActiveSupport::Concern

  included do
    has_many :collection_links,
      ->(entry) { where linked_type: entry.class.base_class.name },
      foreign_key: :linked_id,
      dependent: :destroy

    has_many :collections, through: :collection_links
  end
end
