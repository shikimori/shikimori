class NameMatch < ActiveRecord::Base
  GROUPS = [:predefined, :name, :alt, :alt2, :alt3, :russian]

  belongs_to :target, polymorphic: true
  enumerize :group, in: GROUPS
  validates :target, :phrase, :group, presence: true
end
