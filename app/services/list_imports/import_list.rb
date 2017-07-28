class ListImports::ImportList
  prepend ActiveCacher.instance

  ADDED = 'added'
  UPDATED = 'updated'
  NOT_IMPORTED = 'not_imported'

  DEFAULT_OUTPUT = { ADDED => [], UPDATED => [], NOT_IMPORTED => [] }

  method_object :list_import, :list
  instance_cache :mismatched_list_entries, :matched_list_entries, :user_rates

  def call
    @list_import.output = DEFAULT_OUTPUT

    import_mismatched
    # import_existing_list_entries
    # import_missing_list_entries

    @list_import.save!
  end

private

  def build_user_rate list_entry
    list_entry.export UserRate.new(
      user: @list_import.user,
      target_id: list_entry[:target_id],
      target_type: list_entry[:target_type]
    )
  end

  def import_mismatched
    user_rates = []

    mismatched_list_entries.each do |list_entry|
      user_rate = build_user_rate(list_entry)

      if user_rate&.valid?
        user_rates << user_rate
        output_imported list_entry
      else
        output_not_imported list_entry
      end
    end

    UserRate.import user_rates
  end

  # def import_existing_list_entries
  # end

  def mismatched_list_entries
    @list.select do |list_entry|
      user_rates.none? do |user_rate|
        user_rate.target_id == list_entry[:target_id].to_i
      end
    end
  end

  def matched_list_entries
    @list - mismatched_list_entries
  end

  def user_rates
    if @list_import.anime?
      @list_import.user.anime_rates.includes(:anime).to_a
    else
      @list_import.user.manga_rates.includes(:manga).to_a
    end
  end

  def output_imported list_entry
    @list_import.output[ADDED] << list_entry
  end

  def output_not_imported list_entry
    @list_import.output[NOT_IMPORTED] << list_entry
  end
end
