class NameMatches::BuildMatches < ServiceObjectBase
  pattr_initialize :entry

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
        priority: entry.kind == :tv ? 0 : 1,
        phrase: phrase,
        target: entry
      )
    end
  end

  def namer
    @namer ||= NameMatches::Namer.instance
  end

  def cleaner
    @cleaner ||= NameMatches::Cleaner.instance
  end
end
