class MigrateReadmangIdToExternalLinks < ActiveRecord::Migration[5.0]
  def up
     Ranobe
      .where.not(read_manga_id: [nil, ''])
      .update_all(read_manga_id: nil)

     Manga
      .where.not(read_manga_id: [nil, ''])
      .each do |manga|
        manga.external_links.create!(
          kind: :readmanga,
          url: url(manga.read_manga_id),
          source: :shikimori
        )
      end
  end

  def down
    ExternalLink.where(kind: :readmanga).delete_all
  end

private

  def url id
    id.starts_with?(ReadMangaImporter::Prefix) ?
      "http://readmanga.me/#{id.sub(ReadMangaImporter::Prefix, '')}" :
      "http://mintmanga.com/#{id.sub(AdultMangaImporter::Prefix, '')}"
  end
end
