class CharactersNamesService
  include Singleton

  RussianReplacements = %w[
    а е ё и о у ы ю я ей ой ом ем ея еем ею эй ия ию ией
  ]
  RussianCleaner = /(?:#{RussianReplacements.join('|')})$/

  # замена имён персонажей с транскрипцией на [character] теги
  def process data, anime
    characters = extract_characters(anime)
    people = extract_people(anime)

    # может быть не строка, а SafeBuffer
    text = (data.class == String ? data : String.new(data)).tr(' ', ' ')

    # данные, по которым будет делаться замена
    matches = extract_transcribed_matches(text, characters, people)
    matches = extract_russian_matches(matches, text, characters)
    matches = variate_matches(matches) { |v| v.split ' ' }
    matches = variate_matches(matches) { |v| russian_variations(v) }

    # замена имён на ббкоды
    replace_names(text, matches)
  end

private

  # выборка персонажей
  def extract_characters anime
    anime.characters.each_with_object({}) do |v, rez|
     rez[v.japanese.cleanup_japanese.delete(' ')] = v if v.japanese.present?
     rez[v.name.delete(' ')] = v
    end
  end

  # выборка людей
  def extract_people anime
    anime.people.each_with_object({}) do |v, rez|
     rez[v.japanese.cleanup_japanese.delete(' ')] = v if v.japanese.present?
     rez[v.name.delete(' ')] = v
    end
  end

  # выборка реальных имён с транскрипцией из текста
  def extract_transcribed_matches text, characters, people
    text.gsub(/
      (?<name> (?: [А-ЯЁA-Z][А-ЯЁа-яё\w\.-]+(\s д[е'])? (?: \s (?=[А-ЯЁA-Z]) )? )+ )
      \s*
      (?: \( | \[ ) (?<japanese> .*? ) (?: \) | \] )
    /x).map do |_v|
      name = $LAST_MATCH_INFO[:name]
      japanese = $LAST_MATCH_INFO[:japanese].cleanup_japanese.delete(' ')

      # отсечение частиц
      fixed_name = name.split(' ').reject { |v| v.pretext? }.join(' ')
      regexp = build_regexp(fixed_name)
      next unless regexp

      if characters.include?(japanese)
        {
          name: fixed_name,
          regex: regexp,
          character: characters[japanese]
        }
      elsif people.include?(japanese)
        {
          name: fixed_name,
          regex: regexp,
          person: people[japanese]
        }
      end
    end
    .compact
  end

  # выборка имён, напрямую совпадающих с именами персонажей в тексте
  def extract_russian_matches matches, text, characters
    characters.each do |_japanese, character|
      next if character.russian.blank?
      next if matches.any? { |v| v[:name] == character.russian }
      next unless text.include? character.russian

      regexp = build_regexp(character.russian)
      next unless regexp

      matches << {
        name: character.russian,
        regex: regexp,
        character: character
      }
    end

    matches
  end

  # регексп, по которому в тексте будет производиться финальная замена
  def build_regexp name
    return if name.blank?

    %r{(?<![\[\]\(\)])\b#{name}\b(?! ?[\[\]\(\)]\/?(?:character|person))(\s*(?:\(|\[).*?(?:\)|\]))?}
  rescue RegexpError
    nil
  end

  # разбивка имён по пробелам
  def variate_matches matches
    # карта существующих имён - нужна, чтобы не было конфликтов имён
    counts_map = matches
      .flat_map { |v| yield(v[:name]) }
      .inject({}) { |rez, v| (rez[v] ||= 0) && (rez[v] += 1) && rez }

    # разбитие имён на части, если в них есть пробелы
    matches
      .flat_map do |data|
        if data.include?(:person)
          [data]
        else
          [data] + yield(data[:name]).map do |name|
            regexp = build_regexp(name)
            if regexp && counts_map[name] == 1 && !name.pretext?
              {
                name: name,
                regex: regexp,
                character: data[:character]
              }
            end
          end
        end
      end
      .compact
      .uniq { |v| v[:name] }
  end

  # замена в тексте имён
  def replace_names text, matches
    matches.each do |data|
      if data.include?(:person)
        text.gsub! data[:regex], "[person=#{data[:person].id}]#{data[:name]}[/person]"
      else
        text.gsub! data[:regex], "[character=#{data[:character].id}]#{data[:name]}[/character]"
      end
    end

    # при именах из нескольких слов могли образоваться вложенные [character] теги - надо их почистить
    text.gsub(/
      \[character=\d+\]
        (?<content>
          [^\[\]]+
          (
            \s*
            \[character=\d+\] .*? \[\/character\]
            \s*
          )+
          [^\[\]]+
        )
      \[\/character\]
    /xi) do |v|
      v.sub(
        $LAST_MATCH_INFO[:content],
        $LAST_MATCH_INFO[:content].gsub(/\[\/?character(=\d+)?\]/, '')
      )
    end
  end

  # различные варианты написания слова с учётом разных падежей
  def russian_variations word
    return [word] if word.size < 3 || word.include?(' ')
    cleaned_word = word.sub(RussianCleaner, '')
    [word, cleaned_word] + RussianReplacements.map { |v| cleaned_word + v }
  end
end
