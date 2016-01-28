class NameMatches::ResolveAmbiguousity < ServiceObjectBase
  pattr_initialize :entries, :options

  def call
    entries = @entries
    entries = resolve_by_year entries, @options[:year] if @options[:year]
    entries = resolve_by_episodes entries, @options[:episodes] if @options[:episodes]
    entries = resolve_by_status entries, @options[:status] if @options[:status]
    entries
  end

private

  def resolve_by_year entries, year
    resolved = entries.select { |v| v.year == year }
    resolved.any? ? resolved : entries
  end

  def resolve_by_episodes entries, episodes
    range = episodes > 5 ? (episodes-episodes/10)..(episodes+episodes/10) : episodes..episodes
    resolved = entries.select { |v| range.include? v.episodes }
    resolved.any? ? resolved : entries
  end

  def resolve_by_status entries, status
    resolved = entries.select { |v| v.status == status }
    resolved.any? ? resolved : entries
  end
end
