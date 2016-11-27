class Elasticsearch::Data::Manga < Elasticsearch::Data::Anime
  KINDS = {
    manga: 10,
    manhwa: 10,
    manhua: 10,
    novel: 9,
    one_shot: 8,
    doujin: 7
  }
end
