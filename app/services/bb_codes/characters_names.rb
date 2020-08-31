# замена имён персонажей с транскрипцией на [character] теги
class BbCodes::CharactersNames
  method_object :data, :entry

  RUSSIAN_REPLACEMENTS = %w[
    а е ё и о у ы ю я ей ой ом ем ея еем ею эй ия ию ией
  ]
  RUSSIAN_CLEANER = /(?:#{RUSSIAN_REPLACEMENTS.join('|')})$/
  CHARACTER_NAME = %r{
    \[character=\d+\]
      (?<content>
        [^\[\]]+
        (?:
          \s*
          \[character=\d+\] .*? \[/character\]
          \s*
        )+
        [^\[\]]+
      )
    \[/character\]
  }xi

  URL_REGEXP = BbCodes::Tags::UrlTag::REGEXP
  URL_PLACEHOLDER = '<<-URL-PLACEHODLER->>'

  def call
    characters = extract_characters(@entry)
    people = extract_people(@entry)

    # может быть не строка, а SafeBuffer
    text = (@data.class == String ? @data : String.new(@data)).tr(' ', ' ')
    text, cache = remove_urls text

    # данные, по которым будет делаться замена
    matches = extract_transcribed_matches(text, characters, people)
    matches = extract_russian_matches(matches, text, characters)
    matches = variate_matches(matches) { |v| v.split ' ' }
    matches = variate_matches(matches) { |v| russian_variations(v) }

    # замена имён на ббкоды
    restore_urls(replace_names(text, matches), cache)
  end

private

  # выборка персонажей
  def extract_characters entry
    entry.characters.each_with_object({}) do |v, rez|
      rez[v.japanese.cleanup_japanese.delete(' ')] = v if v.japanese.present?
      rez[v.name.delete(' ')] = v
    end
  end

  # выборка людей
  def extract_people entry
    entry.people.each_with_object({}) do |v, rez|
      rez[v.japanese.cleanup_japanese.delete(' ')] = v if v.japanese.present?
      rez[v.name.delete(' ')] = v
    end
  end

  # выборка реальных имён с транскрипцией из текста
  def extract_transcribed_matches text, characters, people
    text.gsub(/
      (?<name> (?: [А-ЯЁA-Z][А-ЯЁа-яё\w.-]+(\s д[е'])? (?: \s (?=[А-ЯЁA-Z]) )? )+ )
      \s*
      (?: \( | \[ ) (?<japanese> .*? ) (?: \) | \] )
    /x).map do |_v|
      name = $LAST_MATCH_INFO[:name]
      japanese = $LAST_MATCH_INFO[:japanese].cleanup_japanese.delete(' ')

      # отсечение частиц
      fixed_name = name.split(' ').reject(&:pretext?).join(' ')
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
    characters.each_value do |character|
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

    %r{(?<![\[\]()])\b#{name}\b(?! ?[\[\]()]/?(?:character|person))(\s*(?:\(|\[).*?(?:\)|\]))?}
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
            next unless regexp && counts_map[name] == 1 && !name.pretext?

            {
              name: name,
              regex: regexp,
              character: data[:character]
            }
          end
        end
      end
      .compact
      .uniq { |v| v[:name] }
  end

  def replace_names text, matches
    replaced_text =
      matches.inject(text) do |memo, data|
        if data.include?(:person)
          replace_person memo, data
        else
          replace_character memo, data
        end
      end

    # при именах из нескольких слов могли образоваться
    # вложенные [character] теги - надо их почистить
    cleanup_overlapped_tags replaced_text
  end

  def replace_person text, data
    text.gsub(
      data[:regex],
      "[person=#{data[:person].id}]#{data[:name]}[/person]"
    )
  end

  def replace_character text, data
    text.gsub(
      data[:regex],
      "[character=#{data[:character].id}]#{data[:name]}[/character]"
    )
  end

  def cleanup_overlapped_tags text
    text.gsub(CHARACTER_NAME) do |v|
      v.sub(
        $LAST_MATCH_INFO[:content],
        $LAST_MATCH_INFO[:content].gsub(%r{\[/?character(=\d+)?\]}, '')
      )
    end
  end

  # различные варианты написания слова с учётом разных падежей
  def russian_variations word
    return [word] if word.size < 3 || word.include?(' ')

    cleaned_word = word.sub(RUSSIAN_CLEANER, '')
    [word, cleaned_word] + RUSSIAN_REPLACEMENTS.map { |v| cleaned_word + v }
  end

  def remove_urls text
    cache = []
    fixed_text = text.gsub(URL_REGEXP) do |match|
      cache << match
      URL_PLACEHOLDER
    end

    [fixed_text, cache]
  end

  def restore_urls text, cache
    text.gsub(URL_PLACEHOLDER) do
      cache.shift
    end
  end
end
