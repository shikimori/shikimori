class MangaPage < ActiveRecord::Base
  belongs_to :chapter, class_name: 'MangaChapter', foreign_key: :manga_chapter_id

  validates :url, presence: true, url: true, uniqueness: true
  validates :number, presence: true
end
