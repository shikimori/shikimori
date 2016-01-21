class NameMatches::Phraser
  CLEANUP = /[-:,.~)(\[\]\/～"'☆†♪]+/mix

  def fix phrases
    if phrases.nil?
      fix ''
    elsif phrases.kind_of? Array
      phrases.map { |phrase| fix phrase }.uniq.select(&:present?)
    else
      phrase = phrases.frozen? ? String.new(phrases) : phrases
      cleanup(phrase.force_encoding('utf-8'))
        .gsub(/ /, '')
        .gsub(/`/, "'")
        .gsub(/ +/, '')
        .strip
    end
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
      .select { |v| fix(v) !~ config.bad_names }
      .select { |v| fix(v).size > 3 }
  end

  # получение различных вариантов написания фразы
  def phrase_variants name, kind=nil, with_splits=true
    return [] if name.nil?

    phrases = Array(cleanup name)

    phrases.concat words_combinations name
    phrases.concat bracket_alternatives name
    phrases.concat split_by_delimiters name.downcase, kind if with_splits

    # транслит
    #phrases = (phrases + phrases.map {|v| Russian::translit v }).uniq

    String::UNACCENTS.each do |word, matches|
      phrases = replace_phrases phrases, matches, word.downcase
    end
    config.synonyms.each do |match, replacement|
      phrases = replace_phrases phrases, match, replacement
    end
    if kind && name.downcase.include?("(#{kind.downcase})")
      phrases = multiply_phrases phrases, "(#{kind})", ''
    end
    phrases.uniq
  end

  # aternative names in brackets
  def bracket_alternatives phrase
    Array(phrase)
      .select { |v| v =~ /[\[\(].{5}.*?[\]\)]/ }
      .flat_map { |v| v.split(/[\(\)\[\]]/).map(&:strip) }
      .map { |v| cleanup v }
  end

  def words_combinations phrases
    Array(phrases)
      .map { |phrase| phrase.split(/-/).map(&:strip).reverse }
      .select { |split| split.all? { |v| v.size >= 4 } }
      .map { |split| cleanup split.join(' ') }
  end

  def cleanup phrase
    phrase.gsub(CLEANUP, '').downcase
  end

  def replace_phrases phrases, from, to
    phrases
      .map { |phrase| phrase.gsub(from, to).gsub(/  +/, ' ').strip }
      .uniq
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

  def config
    NameMatches::Config.instance
  end
end
