class CharactersService
  include Singleton

  RussianReplacements = %w{
    а е ё и о у ы ю я ей ой ом ем ея еем ею эй ия ию ией
  }
  RussianCleaner = %r{(?:#{RussianReplacements.join('|')})$}

  # замена имён персонажей с транскрипцией на [character] теги
  def process(data, anime)
    characters = extract_characters(anime)
    people = extract_people(anime)

    # может быть не строка, а SafeBuffer
    text = (data.class == String ? data : String.new(data)).gsub(' ', ' ')

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
  def extract_characters(anime)
     anime.characters.all.inject({}) do |rez,v|
      rez[v.japanese.cleanup_japanese.gsub(' ', '')] = v if v.japanese.present?
      rez[v.name.gsub(' ', '')] = v
      rez
    end
  end

  # выборка людей
  def extract_people(anime)
     anime.people.all.inject({}) do |rez,v|
      rez[v.japanese.cleanup_japanese.gsub(' ', '')] = v if v.japanese.present?
      rez[v.name.gsub(' ', '')] = v
      rez
    end
  end

  # выборка реальных имён с транскрипцией из текста
  def extract_transcribed_matches(text, characters, people)
    text.gsub(/
      (?<name> (?: [А-ЯЁA-Z][А-ЯЁа-яё\w\.-]+(\s д[е'])? (?: \s (?=[А-ЯЁA-Z]) )? )+ )
      \s*
      (?: \( | \[ ) (?<japanese> .*? ) (?: \) | \] )
    /x).map do |v|
      name, japanese = $~[:name], $~[:japanese].cleanup_japanese.gsub(' ', '')

      # отсечение частиц
      fixed_name = name.split(' ').select {|v| !v.pretext? }.join(' ')
      if fixed_name.present? && characters.include?(japanese)
        {
          name: fixed_name,
          regex: build_regexp(fixed_name),
          character: characters[japanese]
        }
      elsif fixed_name.present? && people.include?(japanese)
        {
          name: fixed_name,
          regex: build_regexp(fixed_name),
          person: people[japanese]
        }
      else
        nil
      end
    end.compact
  end

  # выборка имён, напрямую совпадающих с именами персонажей в тексте
  def extract_russian_matches(matches, text, characters)
    characters.each do |japanese,character|
      next if character.russian.blank?
      next if matches.any? { |v| v[:name] == character.russian }
      next unless text.include? character.russian
      matches << {
        name: character.russian,
        regex: build_regexp(character.russian),
        character: character
      }
    end

    matches
  end

  # регексп, по которому в тексте будет производиться финальная замена
  def build_regexp(name)
    %r{(?<![\[\]\(\)])\b#{name}\b(?![\[\]\(\)]\/?(?:character|person))(\s*(?:\(|\[).*?(?:\)|\]))?}
  end

  # разбивка имён по пробелам
  def variate_matches(matches, &variator)
    # карта существующих имён - нужна, чтобы не было конфликтов имён
    counts_map = matches.map { |v| variator.(v[:name]) }
                        .flatten
                        .inject({}) { |rez,v| (rez[v] ||= 0) and rez[v] += 1 and rez }

    # разбитие имён на части, если в них есть пробелы
    matches.map do |data|
      if data.include?(:person)
        [data]
      else
        [data] + variator.(data[:name]).map do |name|
          if name.present? && counts_map[name] == 1 && !name.pretext?
            {
              name: name,
              regex: build_regexp(name),
              character: data[:character]
            }
          else
            nil
          end
        end
      end
    end.flatten.compact.uniq_by { |v| v[:name] }
  end

  # замена в тексте имён
  def replace_names(text, matches)
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
      v.sub($~[:content], $~[:content].gsub(/\[\/?character(=\d+)?\]/, ''))
    end
  end

  # различные варианты написания слова с учётом разных падежей
  def russian_variations(word)
    return [word] if word.size < 3 || word.include?(' ')
    cleaned_word = word.sub(RussianCleaner, '')
    [word, cleaned_word] + RussianReplacements.map {|v| cleaned_word + v }
  end
end
