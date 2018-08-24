module StylesConcern
  extend ActiveSupport::Concern

  included do
    owner_type = name

    belongs_to :style, optional: true
    has_many :styles, -> { where owner_type: owner_type },
      foreign_key: :owner_id,
      dependent: :destroy

    after_create :assign_style
  end

private

  def assign_style
    create_style! owner: self
    save!
  end
end
