class NameMatches::Phraser
  CONFIG = YAML::load_file Rails.root.join 'config/app/names_matches_phraser.yml'

  CLEANUP = /[-:,.~)(\[\]\/～"'☆†♪]+/mix

  BAD_NAMES = /\A(#{CONFIG[:bad_names].join '|'})\Z/mix

  LETTER_SYNONYMS = CONFIG[:letter_synonyms]
    .each_with_object([]) do |(left, right), memo|
      memo.push [left, right]
      memo.push [right, left]
    end
  WORD_SYNONYMS = CONFIG[:word_synonyms]
    .each_with_object([]) do |(left, right), memo|
      memo.push [/\b#{left}\b/, right]
      memo.push [/\b#{right}\b/, left]
    end
  REGEXP_REPLACES = CONFIG[:regexp_replaces].map do |left, right|
    [/#{left}/, right]
  end
  SYNONYMS = LETTER_SYNONYMS + WORD_SYNONYMS + REGEXP_REPLACES

  def fix phrases
    if phrases.nil?
      fix ''
    elsif phrases.kind_of? Array
      phrases.map { |phrase| fix phrase }.uniq.compact
    else
      cleanup(phrases.force_encoding('utf-8'))
        .gsub(/ /, '')
        .gsub(/`/, "'")
        .gsub(/ +/, '')
        .strip
    end
  end

  # множественная замена фразы на альтернативы
  def multiply_phrases phrases, from, to
    multiplies = []

    phrases.each do |phrase|
      next_phrase = phrase

      10.times do
        replaced = next_phrase.sub(from, to).strip

        if replaced != next_phrase
          multiplies << replaced
          next_phrase = replaced
        else
          break
        end
      end
    end

    multiplies.any? ? phrases + multiplies : phrases
  end

  # все возможные варианты написания имён
  def variants names, with_splits=true
    Array(names)
      .map(&:downcase)
      .map { |name| fix phrase_variants(name, nil, with_splits) }
      .flatten
      .uniq
      .select(&:present?)
  end

  # разбитие фразы по запятым, двоеточиям и тире
  def split_by_delimiters name, kind=nil
    names = (name =~ /:|-/ ?
      name.split(/:|-/).select {|s| s.size > 7 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      []) +
    (name =~ /,/ ?
      name.split(/,/).select {|s| s.size > 10 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      [])

    names
      .flatten
      .select { |v| fix(v) !~ BAD_NAMES }
      .select { |v| fix(v).size > 3 }
  end


  # получение различных вариантов написания фразы
  def phrase_variants name, kind=nil, with_split=true
    return [] if name.nil?

    phrases = Array(cleanup name)

    phrases.concat split_by_delimiters(name, kind) if with_split

    # альтернативные названия в скобках
    phrases = phrases + phrases
      .select { |v| v =~ /[\[\(].{5}.*?[\]\)]/ }
      .map { |v| v.split(/[\(\)\[\]]/).map(&:strip) }
      .flatten

    # перестановки
    phrases = phrases + phrases
      .select { |v| v =~ /-/ }
      .map { |v| v.split(/-/).map(&:strip).reverse.join(' ') }
      .flatten

    # транслит
    #phrases = (phrases + phrases.map {|v| Russian::translit v }).uniq

    String::UNACCENTS.each do |word, matches|
      phrases = multiply_phrases phrases, matches, word.downcase
    end
    SYNONYMS.each do |match, replacement|
      phrases = multiply_phrases phrases, match, replacement
    end
    phrases = multiply_phrases phrases, "(#{kind})", '' if kind && name.include?("(#{kind.downcase})")
    phrases.uniq
  end

  def cleanup phrase
    phrase.gsub(CLEANUP, '').downcase
  end
end
