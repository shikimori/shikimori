class MalParsers::AnimeAuthorized < MalParser::Entry::Anime
  include MalParsers::ParseAuthorized

  def type
    'anime'
  end
end
