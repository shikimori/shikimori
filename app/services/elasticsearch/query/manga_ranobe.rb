class Elasticsearch::Query::MangaRanobe < Elasticsearch::Query::Anime
  def index_klass
    MangasRanobeIndex
  end
end
