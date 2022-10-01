class NameMatches::Namer
  include Singleton

  def initialize
    @phraser ||= NameMatches::Phraser.instance
    @cleaner ||= NameMatches::Cleaner.instance
    @config ||= NameMatches::Config.instance
  end

  def predefined entry
    @config.predefined_names(entry.class)
      .select { |_, id| id == entry.id }
      .map { |phrase, _| @cleaner.finalize phrase }
  end

  def name entry
    names = [
      entry.name,
      with_kind(entry.name, entry),
      with_year(entry.name, entry)
    ]
    @cleaner.finalize names
  end

  def alt entry
    names = alternatives(entry).flat_map do |name|
      [name, with_kind(name, entry), with_year(name, entry)]
    end

    @phraser.variate(
      [entry.name] + alternatives(entry) + names,
      do_splits: true,
      kind: entry.kind,
      year: entry.year
    ) - name(entry)
  end

  def alt2 entry
    @cleaner.finalize alternatives(entry)
  end

  def alt3 entry
    other_names = name(entry) + alt2(entry) + alt(entry)
    names = with_bang_variants other_names, entry
    @cleaner.finalize(names) - other_names
  end

  def russian entry
    names = [
      entry.russian,
      with_kind(entry.russian, entry),
      with_year(entry.russian, entry)
    ]
    @cleaner.finalize names
  end

  def russian_alt entry
    other_names = russian(entry)
    names = with_bang_variants other_names, entry
    @cleaner.finalize(names) - other_names
  end

private

  def alternatives entry
    (
      Array(entry.synonyms) + Array(entry.english) + Array(entry.japanese)
    ).compact
  end

  def with_kind name, entry
    "#{name} #{entry.kind}" if name.present?
  end

  def with_year name, entry
    "#{name} #{entry.aired_on.year}" if name.present? && entry.aired_on.present?
  end

  def without_suffix name
    @cleaner.cleanup name
  end

  def with_bang_variants names, entry
    names + names.map { |v| v.gsub('!', '') }
  end

  def post_process names
    names.compact.map { |name| @cleaner.post_process name }.uniq
  end
end
