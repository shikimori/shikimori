module ClubsConcern
  extend ActiveSupport::Concern

  included do |klass|
    has_many :club_links, -> { where linked_type: klass.name },
      foreign_key: :linked_id,
      dependent: :destroy

    has_many :clubs, through: :club_links
  end
end
