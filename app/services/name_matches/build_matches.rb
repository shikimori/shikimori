class NameMatches::BuildMatches < ServiceObjectBase
  pattr_initialize :entry

  PRIORITIES = {
    tv: 0,
    movie: 1,
    special: 10,
    one_shot: 8,
    doujin: 10
  }
  DEFAULT_PRIORITY = 5

  def call
    NameMatch::GROUPS
      .map { |group| [group, namer.send(group, entry)] }
      .flat_map { |group, phrases| build group, cleaner.finalize(phrases) }
      .uniq(&:phrase)
  end

private

  def build group, phrases
    phrases.map do |phrase|
      NameMatch.new(
        group: NameMatch::GROUPS.index(group),
        priority: priority(entry.kind) || DEFAULT_PRIORITY,
        phrase: phrase,
        target: entry
      )
    end
  end

  def priority kind
    PRIORITIES[kind.to_sym] if kind
  end

  def namer
    @namer ||= NameMatches::Namer.instance
  end

  def cleaner
    @cleaner ||= NameMatches::Cleaner.instance
  end
end
