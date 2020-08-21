# TODO: use chewy to search in elasticsearch instead of database
class BbCodes::DbEntryMention
  method_object :text

  BB_CODES = (
    BbCodes::Text::SIMPLE_BB_CODES +
    BbCodes::Text::COMPLEX_BB_CODES +
    BbCodes::Text::DB_ENTRY_BB_CODES +
    BbCodes::Text::TAGS_LIST
  ).uniq

  REGEXP = %r{\[(?!/|(?:#{BB_CODES.join '|'})\b)([^\]\n]++)\]}

  def call
    text.gsub REGEXP do |matched|
      name = Regexp.last_match(1).gsub('&#x27;', "'").gsub('&quot;', '"')
      entry = match_entry name
      entry ? "[#{entry.class.name.downcase}=#{entry.id}]" : matched
    end
  end

private

  def match_entry name
    splitted_name = name.split(' ')
    reversed_name = splitted_name.reverse.join(' ') if splitted_name.many?

    if name.contains_russian?
      find_russian name, reversed_name
    elsif name != 'manga' && name != 'list' && name != 'anime'
      find_name name, reversed_name
    end
  end

  def find_russian name, reversed_name
    find_by name, reversed_name, :russian
  end

  def find_name name, reversed_name
    find_by(name, reversed_name, :name) ||
      Person.find_by(name: name) ||
      (Person.find_by(name: reversed_name) if reversed_name)
  end

  def find_by name, reversed_name, field
    Anime.order(score: :desc).find_by(field => name) ||
      Manga.order(score: :desc).find_by(field => name) ||
      Character.find_by(field => name) ||
      (Character.find_by(field => reversed_name) if reversed_name)
  end
end
