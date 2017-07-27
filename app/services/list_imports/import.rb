class ListImports::Import
  method_object :list_import

  ADDED = 'added'
  UPDATED = 'updated'
  NOT_IMPORTED = 'not_imported'

  ERROR_EXCEPTION = 'error_exception'
  ERROR_WRONG_LIST_TYPE = 'wrong_list_type'

  def call
    User.transaction { do_import }

  rescue StandardError => e
    @list_import.to_failed!
    @list_import.update! output: exception_error(e)
  end

private

  def do_import
    @list_import.output = { ADDED => [], UPDATED => [], NOT_IMPORTED => [] }

    import ListImports::Parse.call(open(ListImport.last.list.path))

    @list_import.save!
    @list_import.finish!
  end

  def import rates_data
  end

  def exception_error exception
    {
      error: {
        type: ERROR_EXCEPTION,
        class: exception.class.name,
        message: exception.message,
        backtrace: exception.backtrace
      }
    }
  end
end
