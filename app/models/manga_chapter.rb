class MangaChapter < ActiveRecord::Base
  belongs_to :manga
  has_many :pages, class_name: 'MangaPage'

  validates :name, presence: true
  validates :url, presence: true, url: true, uniqueness: true
end
