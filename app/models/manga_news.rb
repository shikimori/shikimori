class MangaNews < AnimeNews
  attr_defaults section_id: -> { SectionIDs[Manga.name] }
end
