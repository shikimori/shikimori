class ListImportView < ViewObjectBase
  pattr_initialize :list_import
  instance_cache :added, :updated, :not_imported

  def added
    @list_import.output[ListImports::ImportList::ADDED]
      .map { |list_entry| ListImports::ListEntry.new list_entry.symbolize_keys }
      .sort_by(&:target_title)
  end

  def not_imported
    @list_import.output[ListImports::ImportList::NOT_IMPORTED]
      .map { |list_entry| ListImports::ListEntry.new list_entry.symbolize_keys }
      .sort_by(&:target_title)
  end
end
