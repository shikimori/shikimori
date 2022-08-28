module ClubsConcern
  extend ActiveSupport::Concern

  included do |klass|
    has_many :club_links, -> { where linked_type: klass.name },
      inverse_of: :linked,
      foreign_key: :linked_id,
      dependent: :destroy

    has_many :clubs, -> { where is_non_thematic: false },
      through: :club_links
  end
end
