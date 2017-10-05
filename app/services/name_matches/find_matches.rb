class NameMatches::FindMatches < ServiceObjectBase
  pattr_initialize :names, :type_klass, :options

  instance_cache :phrase_variants

  def call
    entries = match_entries

    if entries.one?
      entries
    else
      NameMatches::ResolveAmbiguousity.call entries, @options
    end
  end

private

  def match_entries
    phrase_variants.each do |phrases|
      matched = find_matches(phrases)
      return matched if matched.any?
    end

    []
  end

  def find_matches phrases
    groups = db_matches(phrases)
      .group_by { |match| "#{match.priority}-#{match.group}" }
      .sort_by(&:first)

    if groups.any?
      groups.first.second
        .map { |match| match.send entry_type }
        .compact
        .uniq
    else
      []
    end
  end

  def phrase_variants
    NameMatches::PhraseToSearchVariants.call @names
  end

  def db_matches phrases
    NameMatch
      .includes(entry_type)
      .where(phrase: phrases)
  end

  def entry_type
    @type_klass.name.downcase.to_sym
  end
end
