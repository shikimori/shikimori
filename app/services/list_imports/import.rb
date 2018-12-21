class ListImports::Import
  method_object :list_import

  def call
    User.transaction { do_import }
  rescue ListImports::ParseFile::BrokenFileError
    specific_error ListImport::ERROR_BROKEN_FILE
  rescue StandardError => e
    exception_error e
  end

private

  def do_import
    list = ListImports::ParseFile.call(File.open(@list_import.list.path))

    if list.empty?
      specific_error ListImport::ERROR_EMPTY_LIST
    elsif wrong_list_type? list
      specific_error ListImport::ERROR_MISMATCHED_LIST_TYPE
    else
      import list
      create_history_entry
      track_achievements
    end
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

  def specific_error error_type
    @list_import.to_failed!
    @list_import.update! output: { error: { type: error_type } }
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

  def wrong_list_type? list
    list.any? do |list_entry|
      list_entry[:target_type].downcase != @list_import.list_type
    end
  end
end
