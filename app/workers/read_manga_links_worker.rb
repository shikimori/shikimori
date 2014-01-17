class ReadMangaLinksWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    Manga.where { source.like '%readmanga%' }.find_each do |manga|
      id = "rm_#{manga.source.sub /^.*\//, ''}"
      if id != manga.read_manga_id
        manga.update_column :read_manga_id, id
      end
    end

    Manga.where { source.like '%adultmanga%' }.find_each do |manga|
      id = "am_#{manga.source.sub /^.*\//, ''}"
      if id != manga.read_manga_id
        manga.update_column :read_manga_id, id
      end
    end
  end
end
