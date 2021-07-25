class CoubTag < ApplicationRecord
  validates :name, presence: true
  validates :name, length: { maximum: 255 }
end
