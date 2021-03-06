module ContestsConcern
  extend ActiveSupport::Concern

  included do
    has_many :contest_links,
      ->(entry) { where linked_type: entry.class.base_class.name },
      foreign_key: :linked_id,
      inverse_of: :item,
      dependent: :destroy

    has_many :contest_winners,
      ->(entry) { where item_type: entry.class.base_class.name },
      foreign_key: :item_id,
      inverse_of: :item,
      dependent: :destroy

    has_many :contests, through: :contest_links
    has_many :contest_suggestions,
      ->(entry) { where item_type: entry.class.base_class.name },
      foreign_key: :item_id,
      inverse_of: :item,
      dependent: :destroy
  end
end
