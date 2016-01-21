class NameMatches::Cleaner
  include Singleton

  CLEANUP = /[-:,.~)(\[\]\/～"'☆†♪]+/mix

  def cleanup phrase
    phrase ||= ''
    phrase = phrase.frozen? ? String.new(phrase) : phrase

    phrase
      .force_encoding('utf-8')
      .gsub(CLEANUP, '')
      .gsub(/`/, "'")
      .gsub(/  +/, ' ')
      .downcase
      .strip
  end

  def desynonymize phrase
    config.synonyms.each do |match, replacement|
      phrase = phrase.gsub(match, replacement).gsub(/  +/, ' ').strip
    end

    phrase
  end

  def fix phrases
    if phrases.kind_of? Array
      phrases.map { |phrase| fix phrase }.uniq.select(&:present?)
    else
      compact cleanup(phrases)
    end
  end

  def finalize phrase
    fix desynonymize cleanup phrase
  end

  def finalizes phrases
    phrases.map { |phrase| finalize phrase }.uniq.select(&:present?)
  end

  def compact phrase
    phrase.gsub(/ +/, '')
  end

private

  def config
    @config ||= NameMatches::Config.instance
  end
end
