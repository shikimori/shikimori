# парсер JSON'а со списком пользователя, приходящего из яваскриптовского парсера MAL'а
class UserListParsers::JsonListParser
  def initialize klass
    @klass = klass
  end

  def parse json
    JSON
      .parse(json)
      .map {|v| @klass == Anime ? parse_anime(v) : parse_manga(v) }
      .compact
  end

private
  def parse_anime entry
    {
      id: entry['id'].to_i,
      episodes: entry['episodes'].to_i,
      rewatches: entry['rewatches'].to_i,
      status: (entry['status'] || 0).to_i,
      score: (entry['score'] || 0).to_i
    }
  end

  def parse_manga entry
    {
      id: entry['id'].to_i,
      volumes: entry['volumes'].to_i,
      chapters: entry['chapters'].to_i,
      rewatches: entry['rewatches'].to_i,
      status: (entry['status'] || 0).to_i,
      score: (entry['score'] || 0).to_i
    }
  end
end
