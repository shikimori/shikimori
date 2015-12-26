class MangaNews < AnimeNews
  attr_defaults forum_id: -> { FORUM_IDS[Manga.name] }
end
