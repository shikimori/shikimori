module ContestsConcern
  extend ActiveSupport::Concern

  included do
    has_many :contest_links,
      ->(entry) { where linked_type: entry.class.name },
      foreign_key: :linked_id,
      dependent: :destroy

    has_many :contest_winners,
      -> { where item_type: entry.class.name },
      foreign_key: :item_id,
      dependent: :destroy
  end
end
