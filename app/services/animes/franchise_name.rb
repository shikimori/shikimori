class Animes::FranchiseName
  method_object :entries, :taken_names

  def call
    present_franchise ||
      new_franchise(true) ||
      new_franchise(false)
  end

private

  def extract_names entries
    entries
      .map(&:name)
      .map { |name| cleanup name }
  end

  def present_franchise
    current_name =
      @entries
        .group_by(&:franchise)
        .reject { |_name, entries| entries.size < @entries.size / 2.0 }
        .first
        &.first

    if current_name && extract_names(@entries).include?(current_name)
      current_name
    end
  end

  def new_franchise do_filter
    extract_names(do_filter ? filter(@entries) : @entries)
      .reject { |name| @taken_names.include? name }
      .min_by(&:length)
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

  def filter entries
    if entries.first.anime?
      entries.reject { |v| v.kind_special? || v.kind_music? }
    else
      entries.reject { |v| v.kind_one_shot? || v.kind_doujin? }
    end
  end
end
