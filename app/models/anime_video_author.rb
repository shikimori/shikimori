class AnimeVideoAuthor < ApplicationRecord
  boolean_attribute :verified

  validates :name, presence: true, uniqueness: true
end
