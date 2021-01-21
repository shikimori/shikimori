class ListImports::ImportList
  prepend ActiveCacher.instance

  ADDED = 'added'
  UPDATED = 'updated'
  NOT_IMPORTED = 'not_imported'
  NOT_CHANGED = 'not_changed'

  DEFAULT_OUTPUT = {
    ADDED => [],
    UPDATED => [],
    NOT_IMPORTED => [],
    NOT_CHANGED => []
  }

  method_object :list_import, :list
  instance_cache :mismatched_list_entries, :matched_list_entries, :current_user_rates

  def call
    @list_import.output = DEFAULT_OUTPUT

    import_mismatched
    import_matched

    @list_import.save!
  end

private

  def build_user_rate list_entry
    list_entry.export UserRate.new(
      user: @list_import.user,
      target_id: list_entry.target_id,
      target_type: list_entry.target_type
    )
  end

  def import_mismatched
    user_rates = []

    mismatched_list_entries.each do |list_entry|
      user_rate = build_user_rate(list_entry)
      next if user_rates.any? { |v| v.target_id == list_entry.target_id } # filter duplicates

      if user_rate&.valid?
        user_rates << user_rate
        output ListImports::ListEntry.build(user_rate), ADDED
      else
        output list_entry, NOT_IMPORTED
      end
    end

    UserRate.import user_rates
  end

  def import_matched
    matched_list_entries.each do |list_entry|
      if @list_import.duplicate_policy_replace?
        replace_duplicate list_entry
      else
        ignore_duplicate list_entry
      end
    end
  end

  def replace_duplicate list_entry
    user_rate = current_user_rates.find { |v| v.target_id == list_entry.target_id }
    old_list_entry = ListImports::ListEntry.build user_rate

    list_entry.export(user_rate)

    unless user_rate.changed?
      return output fill_title(list_entry, user_rate), NOT_CHANGED
    end

    if user_rate.valid?
      user_rate.save!
      output_updated old_list_entry, ListImports::ListEntry.build(user_rate)
    else
      # have to restore model to previos state
      # without it ListImports::ListEntry.build above could fail when
      # imported list has duplicated record
      user_rate.changes.each { |field, values| user_rate[field] = values.first }
      output list_entry, NOT_IMPORTED
    end
  end

  def ignore_duplicate list_entry
    output list_entry, NOT_IMPORTED
  end

  def mismatched_list_entries
    @list.select do |list_entry|
      current_user_rates.none? do |user_rate|
        user_rate.target_id == list_entry.target_id
      end
    end
  end

  def matched_list_entries
    @list - mismatched_list_entries
  end

  def current_user_rates
    if @list_import.anime?
      @list_import.user.anime_rates.includes(:anime).to_a
    else
      @list_import.user.manga_rates.includes(:manga).to_a
    end
  end

  def output list_entry, key
    @list_import.output[key] << list_entry
  end

  def output_updated old_list_entry, new_list_entry
    @list_import.output[UPDATED] << [old_list_entry, new_list_entry]
  end

  def fill_title list_entry, user_rate
    if list_entry.target_title.blank?
      list_entry.target_title =
        UsersHelper.localized_name user_rate.target, @list_import.user
    end

    list_entry
  end
end
