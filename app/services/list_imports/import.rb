class ListImports::Import
  method_object :list_import

  def call
    User.transaction do
      ListImports::Parse.call open(ListImport.last.list.path)
      list_import.finish!
    end
  end
end
