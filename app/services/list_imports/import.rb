class ListImports::Import
  method_object :list_import

  def call
    User.transaction { do_import }

  rescue StandardError => e
    @list_import.to_failed!
    @list_import.update! output: {
      error: {
        class: e.class.name,
        message: e.message,
        backtrace: e.backtrace
      }
    }
  end

private

  def do_import
    rates_data = ListImports::Parse.call open(ListImport.last.list.path)
    import rates_data
    @list_import.finish!
  end
end
