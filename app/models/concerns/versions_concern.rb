module VersionsConcern
  extend ActiveSupport::Concern

  included do
    has_many :versions,
      ->(entry) { where item_type: entry.class.base_class.name },
      foreign_key: :item_id,
      dependent: :destroy
  end
end
