class NameMatches::Namer
  include Singleton

  delegate :cleanup, :fix, :finalize, :finalizes, to: :cleaner
  delegate :phrase_variants, to: :phraser

  def predefined entry
    config.predefined_names(entry.class)
      .select { |_, id| id == entry.id }
      .map { |phrase, _| cleaner.post_process phrase }
  end

  def name entry
    post_process [
      entry.name,
      with_kind(entry.name, entry),
      with_year(entry.name, entry)
    ]
  end

  def alt entry
    alternatives(entry).flat_map do |name|
      post_process [with_kind(name, entry), with_year(name, entry)]
    end
  end

  def alt2 entry
    post_process alternatives(entry)
  end

  def alt3 entry
    alt_names = name(entry) + alt2(entry) + alt(entry)

    names = alt_names
      .flat_map { |name| post_process(phrase_variants name, entry.kind) }
      .compact

    post_process(names + names.map { |v| v.gsub('!', '') })
  end

  def russian entry
    names = [entry.russian, fix(entry.russian), fix(phrase_variants(entry.russian))]
      .flatten
      .compact
      .map(&:downcase)

    (names + names.map {|v| v.gsub('!', '') }).uniq
  end

  def russian2 entry
  end

  def russian3 entry
  end

private

  def alternatives entry
    Array(entry.synonyms) + Array(entry.english) + Array(entry.japanese)
  end

  def with_kind name, entry
    "#{name} #{entry.kind}" if entry.kind
  end

  def with_year name, entry
    "#{name} #{entry.aired_on.year}" if entry.aired_on
  end

  def post_process names
    names.compact.map { |name| cleaner.post_process name }.uniq
  end

  def phraser
    @phraser ||= NameMatches::Phraser.instance
  end

  def cleaner
    @cleaner ||= NameMatches::Cleaner.instance
  end

  def config
    @config ||= NameMatches::Config.instance
  end
end
