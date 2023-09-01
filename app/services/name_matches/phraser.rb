class NameMatches::Phraser
  include Singleton

  def initialize
    @cleaner = NameMatches::Cleaner.instance
    @config = NameMatches::Config.instance
  end

  # все возможные варианты написания имён
  # def variants names, do_splits = true
    # finalize Array(names).flat_map { |name| variate name, do_splits }
  # end

  # получение различных вариантов написания фразы
  def variate phrases, do_splits: true, kind: nil, year: nil
    phrases = @cleaner.cleanup(Array(phrases))
    return [] if phrases.empty?

    phrases.concat words_combinations phrases
    phrases.concat bracket_alternatives phrases
    phrases.concat split_by_delimiters phrases, kind if do_splits

    # транслит
    #phrases = (phrases + phrases.map {|v| Russian::translit v }).uniq

    phrases = phrases.map { |phrase| @cleaner.desynonymize phrase }

    if do_splits
      @config.splitters.each do |splitter|
        phrases = multiply phrases, splitter, ''
      end
    end

    # if kind && name.downcase.include?("(#{kind.downcase})")
      # phrases = multiply phrases, "(#{kind})", ''
    # end

    @cleaner.finalize phrases
 end

  # разбитие фразы по запятым, двоеточиям и тире
  def split_by_delimiters phrases, kind=nil
    phrases.flat_map do |name|
      names = (name =~ /:|-/ ?
        name.split(/:|-/).select {|s| s.size > 7 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
        []) +
      (name =~ /,/ ?
        name.split(/,/).select {|s| s.size > 10 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
        [])

      names
        .flatten
        .select { |v| @cleaner.finalize(v) !~ @config.bad_names }
        .select { |v| @cleaner.finalize(v).size > 3 }
    end
  end

  # aternative names in brackets
  def bracket_alternatives phrases
    phrases
      .select { |v| v =~ /[\[\(].{5}.*?[\]\)]/ }
      .flat_map { |v| v.split(/[\(\)\[\]]/).map(&:strip) }
      .map { |phrase| @cleaner.cleanup phrase }
  end

  def words_combinations phrases
   phrases
      .map { |phrase| phrase.split(/-/).map(&:strip).reverse }
      .select { |split| split.all? { |v| v.size >= 4 } }
      .map { |split| split.join(' ') }
  end

  def replace_regexp phrases, from, to
    phrases
      .map { |phrase| phrase.gsub(from, to).gsub(/  +/, ' ').strip }
      .uniq
  end

  # множественная замена фразы на альтернативы
  def multiply phrases, from, to
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
end
