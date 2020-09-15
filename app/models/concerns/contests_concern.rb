module ContestsConcern
  extend ActiveSupport::Concern

  included do
    has_many :contest_links,
      ->(entry) { where linked_type: entry.class.base_class.name },
      foreign_key: :linked_id,
      dependent: :destroy

    has_many :contest_winners,
      ->(entry) { where item_type: entry.class.base_class.name },
      foreign_key: :item_id,
      dependent: :destroy

    has_many :contests, through: :contest_links
  end
end
