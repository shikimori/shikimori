module VersionsConcern
  extend ActiveSupport::Concern

  included do
    has_many :versions,
      -> { where item_type: entry.class.name },
      foreign_key: :item_id,
      dependent: :destroy
  end
end
