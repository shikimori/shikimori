class ListImports::Import
  method_object :list_import

  ADDED = 'added'
  UPDATED = 'updated'
  NOT_IMPORTED = 'not_imported'

  ERROR_EXCEPTION = 'error_exception'
  ERROR_EMPTY_LIST = 'empty_list'
  ERROR_WRONG_LIST_TYPE = 'wrong_list_type'

  DEFAULT_OUTPUT = { ADDED => [], UPDATED => [], NOT_IMPORTED => [] }

  def call
    User.transaction { do_import }
  rescue StandardError => e
    exception_error e
  end

private

  def do_import
    list = ListImports::Parse.call(open(ListImport.last.list.path))

    if list.empty?
      specific_error ERROR_EMPTY_LIST
    elsif wrong_list_type? list
      specific_error ERROR_WRONG_LIST_TYPE
    else
      import list
    end
  end

  def import _rates_data
    @list_import.output = DEFAULT_OUTPUT

    @list_import.save!
    @list_import.finish!
  end

  def specific_error error_type
    @list_import.to_failed!
    @list_import.update! output: { error: { type: error_type } }
  end

  # rubocop:disable MethodLength
  def exception_error exception
    @list_import.to_failed!
    @list_import.update!(
      output: {
        error: {
          type: ERROR_EXCEPTION,
          class: exception.class.name,
          message: exception.message,
          backtrace: exception.backtrace
        }
      }
    )
  end
  # rubocop:enable MethodLength

  def wrong_list_type? list
    list.any? { |entry| entry[:target_type].downcase != @list_import.list_type }
  end
end
