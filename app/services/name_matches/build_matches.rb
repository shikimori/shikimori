class NameMatches::BuildMatches < ServiceObjectBase
  pattr_initialize :entry

  delegate *NameMatch::GROUPS, to: :namer
  delegate :finalizes, to: :cleaner


  def call
    NameMatch::GROUPS
      .map { |group| [group, send(group, entry)] }
      .flat_map { |group, phrases| build group, finalizes(phrases) }
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
