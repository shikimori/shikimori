class Animes::FranchiseName
  method_object :entries, :taken_names

  def call
    present_franchise || new_franchise
  end

private

  def present_franchise
    entries
      .group_by(&:franchise)
      .reject { |_name, entries| entries.size < @entries.size / 2.0 }
      .first
      &.first
  end

  def new_franchise
    @entries
      .map(&:name)
      .map { |name| cleanup name }
      .reject { |name| @taken_names.include? name }
      .sort_by(&:length)
      .first
  end

  def cleanup name
    name
      .tr(' ', '_')
      .gsub(/:.*$/, '')
      .gsub(/[^A-z]/, '_')
      .gsub(/__+/, '_')
      .gsub(/^_|_$/, '')
      .downcase
  end
end
