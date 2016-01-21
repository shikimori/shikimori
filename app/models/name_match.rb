class NameMatch < ActiveRecord::Base
  belongs_to :target, polymorphic: true

  validates :target, :phrase, presence: true
  validates :group,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  GROUPS = [:predefined, :name, :alt, :alt2, :alt3, :russian]
end
