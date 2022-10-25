class ListImports::Import
  method_object :list_import

  REQUIRED_FIELDS = %i[target_type target_id status]

  EMPTY_LIST_ERROR_OUTPUT = { type: ListImport::ERROR_EMPTY_LIST }
  MISMATCHED_LIST_ERROR_OUTPUT = { type: ListImport::ERROR_MISMATCHED_LIST_TYPE }
  BROKEN_FILE_ERROR_OUTPUT = { type: ListImport::ERROR_BROKEN_FILE }

  def call
    User.transaction { do_import }
  rescue ListImports::ParseFile::BrokenFileError
    specific_error BROKEN_FILE_ERROR_OUTPUT
  rescue StandardError => e
    exception_error e
  end

private

  def do_import
    list = ListImports::ParseFile.call File.open(@list_import.list.path)

    return specific_error EMPTY_LIST_ERROR_OUTPUT if list.empty?
    return missing_fields_error(list) if missing_fields? list
    return specific_error MISMATCHED_LIST_ERROR_OUTPUT if wrong_list_type? list

    import list
    create_history_entry
    track_achievements
  end

  def import list
    ListImports::ImportList.call @list_import, list

    @list_import.save!
    @list_import.finish!
  end

  def track_achievements
    Achievements::Track.perform_async(
      @list_import.user_id,
      nil,
      Types::Neko::Action[:reset]
    )
  end

  def create_history_entry
    UserHistory.create!(
      user_id: @list_import.user_id,
      action: @list_import.anime? ?
        UserHistoryAction::ANIME_IMPORT :
        UserHistoryAction::MANGA_IMPORT,
      value: @list_import.output[ListImports::ImportList::ADDED].size +
        @list_import.output[ListImports::ImportList::UPDATED].size
    )
  end

  def specific_error error_output
    @list_import.to_failed!
    @list_import.update! output: { error: error_output }
  end

  def exception_error exception
    @list_import.to_failed!
    @list_import.update!(
      output: {
        error: {
          type: ListImport::ERROR_EXCEPTION,
          class: exception.class.name,
          message: exception.message,
          backtrace: exception.backtrace
        }
      }
    )
  end

  def missing_fields_error list
    specific_error(
      type: ListImport::ERROR_MISSING_FIELDS,
      fields: missing_fields(list)
    )
  end

  def wrong_list_type? list
    list.any? do |list_entry|
      list_entry.target_type.downcase != @list_import.list_type
    end
  end

  def missing_fields? list
    missing_fields(list).any?
  end

  def missing_fields list
    REQUIRED_FIELDS.select do |field|
      list[0].send(field).blank?
    end
  end
end
