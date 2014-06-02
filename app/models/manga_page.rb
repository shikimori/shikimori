class MangaPage < ActiveRecord::Base
  #belongs_to :manga
  belongs_to :chapter, class_name: 'MangaChapter', foreign_key: :manga_chapter_id

  #has_attached_file :image,
    #styles: {
      #original: ['225>x350>', :jpg],
      #preview: ['80x120>', :jpg],
    #},
    #url: "/images/manga_online/:manga_id/:chapter_name/:style/:number.:extension",
    #path: ":rails_root/public/images/manga_online/:manga_id/:chapter_name/:style/:number.:extension"

  validates :url, presence: true, url: true, uniqueness: true
  validates :number, presence: true
  #validates :image, attachment_content_type: { content_type: /\Aimage/ }

  def load_image
    #self.image = open_image url
    #self.save
    unless File.exists? path
      image = open_image url
      Dir.mkdir path_manga unless Dir.exists? path_manga
      Dir.mkdir path_chapter unless Dir.exists? path_chapter
      File.open(path, 'wb+') { |f| f.write image.read }
    end
    self.update! image_file_name: asset_path
  end

  def path
    File.join Rails.root, 'public', asset_path
  end

  def asset_path
    File.join 'images/manga_online', manga_id.to_s, chapter.name, "#{number}.jpg"
  end

  def chapter_path
    File.join manga_path, chapter.name
  end

  def manga_path
    File.join Rails.root, 'public/images/manga_online', manga_id.to_s
  end

  def manga_id
    chapter.manga_id
  end
end
