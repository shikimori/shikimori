class NameMatches::Cleaner
  include Singleton

  CLEANER = /[.~\/～"'☆†♪]+/mix
  FINALIZER = /[-:,)(\[\]]/mix

  def initialize
    @config ||= NameMatches::Config.instance
  end

  def finalize arg
    if arg.kind_of? Array
      arg.map { |phrase| finalize phrase }.uniq.select(&:present?)
    else
      compact post_process arg
    end
  end

  def post_process phrase
    desynonymize cleanup(phrase).gsub(FINALIZER, '')
  end

  def cleanup arg
    if arg.kind_of? Array
      arg.map { |phrase| cleanup phrase }
    else
      arg ||= ''
      arg = arg.frozen? ? String.new(arg) : arg

      arg
        .force_encoding('utf-8')
        .gsub(CLEANER, '')
        .gsub(/`/, "'")
        .gsub(/  +/, ' ')
        .downcase
        .strip
    end
  end

  def desynonymize phrase
    @config.synonyms.each do |match, replacement|
      phrase = phrase.gsub(match, replacement).gsub(/  +/, ' ').strip
    end

    phrase
  end

  def compact phrases
    if phrases.kind_of? Array
      phrases.map { |phrase| compact phrase }.uniq.select(&:present?)
    else
      phrases.gsub(/ +/, '')
    end
  end

  # TODO: remove
  def fix phrases
    if phrases.kind_of? Array
      phrases.map { |phrase| fix phrase }.uniq.select(&:present?)
    else
      compact cleanup(phrases)
    end
  end
end
