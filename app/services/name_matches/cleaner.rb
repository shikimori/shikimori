class NameMatches::Cleaner
  include Singleton

  CLEANER = /[.~\/～"'☆†♪]+/mix
  FINALIZER = /[-:,)(\[\]]/mix

  ACCENTS = {
    'A' => /[ÀÁÂÃÄÅĀĂǍẠẢẤẦẨẪẬẮẰẲẴẶǺĄ]/,
    'a' => /[àáâãäåāăǎạảấầẩẫậắằẳẵặǻą]/,
    'C' => /[ÇĆĈĊČ]/,
    'c' => /[çćĉċč]/,
    'D' => /[ÐĎĐ]/,
    'd' => /[ďđ]/,
    'E' => /[ÈÉÊËĒĔĖĘĚẸẺẼẾỀỂỄỆ]/,
    'e' => /[èéêëēĕėęěẹẻẽếềểễệ]/,
    'G' => /[ĜĞĠĢ]/,
    'g' => /[ĝğġģ]/,
    'H' => /[ĤĦ]/,
    'h' => /[ĥħ]/,
    'I' => /[ÌÍÎÏĨĪĬĮİǏỈỊ]/,
    'J' => /[Ĵ]/,
    'j' => /[ĵ]/,
    'K' => /[Ķ]/,
    'k' => /[ķ]/,
    'L' => /[ĹĻĽĿŁ]/,
    'l' => /[ĺļľŀł]/,
    'N' => /[ÑŃŅŇ]/,
    'n' => /[ñńņňŉ]/,
    'O' => /[ÒÓÔÕÖØŌŎŐƠǑǾỌỎỐỒỔỖỘỚỜỞỠỢ]/,
    'o' => /[òóôõöøōŏőơǒǿọỏốồổỗộớờởỡợð]/,
    'R' => /[ŔŖŘ]/,
    'r' => /[ŕŗř]/,
    'S' => /[ŚŜŞŠ]/,
    's' => /[śŝşš]/,
    'T' => /[ŢŤŦ]/,
    't' => /[ţťŧ]/,
    'U' => /[ÙÚÛÜŨŪŬŮŰŲƯǓǕǗǙǛỤỦỨỪỬỮỰ]/,
    'u' => /[ùúûüũūŭůűųưǔǖǘǚǜụủứừửữự]/,
    'W' => /[ŴẀẂẄ]/,
    'w' => /[ŵẁẃẅ]/,
    'Y' => /[ÝŶŸỲỸỶỴ]/,
    'y' => /[ýÿŷỹỵỷỳ]/,
    'Z' => /[ŹŻŽ]/,
    'z' => /[źżž]/,
    # Ligatures
    'AE' => /[Æ]/,
    'ae' => /[æ]/,
    'OE' => /[Œ]/,
    'oe' => /[œ]/
  }

  def initialize
    @config = NameMatches::Config.instance
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
      arg = String.new(arg) if arg.frozen?
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

    ACCENTS.each do |word, matches|
      phrase = phrase.gsub(matches, word)
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
end
