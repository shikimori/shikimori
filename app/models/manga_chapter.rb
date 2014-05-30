class MangaChapter < ActiveRecord::Base
  belongs_to :manga

  validates :name, presence: true
  validates :url, presence: true, url: true, uniqueness: true
end
