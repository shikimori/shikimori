class AnimeVideoAuthor < ApplicationRecord
  has_many :anime_videos, dependent: :restrict_with_exception

  boolean_attribute :verified

  validates :name, presence: true, uniqueness: true

  def name= value
    super value.to_s.strip[0..254]
  end
end
