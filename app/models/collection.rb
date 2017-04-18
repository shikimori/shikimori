class Collection < ApplicationRecord
  belongs_to :user

  validates :name, :user, presence: true
  validates :locale, presence: true

  enumerize :locale, in: %i(ru en), predicates: { prefix: true }
end
