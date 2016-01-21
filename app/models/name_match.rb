class NameMatch < ActiveRecord::Base
  belongs_to :target, polymorphic: true

  validates :target, :phrase, presence: true
  validates :group, :priority,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  GROUPS = [
    :predefined,
    :name,
    :alt, :alt2, :alt3,
    :russian, :russian2, :russian3
  ]
end
