module ClubsConcern
  extend ActiveSupport::Concern

  included do
    has_many :club_links, -> { where linked_type: name },
      foreign_key: :linked_id,
      dependent: :destroy

    has_many :clubs, through: :club_links
  end
end
