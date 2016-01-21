class NameMatches::Config
  include Singleton
  prepend ActiveCacher.instance

  instance_cache :synonyms, :letter_synonyms, :word_synonyms, :regexp_replaces

  def config
    @config ||= YAML::load_file Rails.root.join 'config/app/names_matches.yml'
  end

  def bad_names
    /\A(#{config[:bad_names].join '|'})\Z/mix
  end

  def synonyms
    letter_synonyms + letter_synonyms + word_synonyms + regexp_replaces
  end

  def predefined_names type
    config[:predefined_names][type.name.downcase.to_sym]
  end

private

  def letter_synonyms
    config[:letter_synonyms].map do |to, from|
      [/(?:#{Array(from).join '|'})/i, to]
    end
  end

  def word_synonyms
    config[:word_synonyms].map do |to, from|
      [/\b(?:#{Array(from).join '|'})\b/i, to]
    end
  end

  def regexp_replaces
    config[:regexp_replaces].map do |left, right|
      [/#{left}/i, right]
    end
  end
end
