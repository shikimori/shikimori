class CoubTag < ApplicationRecord
  validate :name, presence: true
end
