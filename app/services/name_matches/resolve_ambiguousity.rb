class NameMatches::ResolveAmbiguousity < ServiceObjectBase
  pattr_initialize :entries, %i[year episodes status kind]

  def call
    entries = @entries
    entries = resolve_by_year entries, @year if @year
    entries = resolve_by_episodes entries, @episodes if @episodes
    entries = resolve_by_status entries, @status if @status
    entries = resolve_by_kind entries, @kind if @kind
    entries
  end

private

  def resolve_by_year entries, year
    resolved = entries.select { |v| v.year == year }
    resolved.any? ? resolved : entries
  end

  def resolve_by_episodes entries, episodes
    range =
      if episodes > 5
        (episodes - episodes / 10)..(episodes + episodes / 10)
      else
        episodes..episodes
      end
    resolved = entries.select { |v| range.include? v.episodes }
    resolved.any? ? resolved : entries
  end

  def resolve_by_status entries, status
    resolved = entries.select { |v| v.status == status }
    resolved.any? ? resolved : entries
  end

  def resolve_by_kind entries, kind
    resolved = entries.select { |v| v.kind == kind }
    resolved.any? ? resolved : entries
  end
end
