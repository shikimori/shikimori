class ListImportView < ViewObjectBase
  pattr_initialize :list_import
  instance_cache :added, :updated, :not_imported

  def added
    output_collection ListImports::ImportList::ADDED
  end

  def not_changed
    output_collection ListImports::ImportList::NOT_CHANGED
  end

  def not_imported
    output_collection ListImports::ImportList::NOT_IMPORTED
  end

private

  def output_collection key
    @list_import.output[key]
      .map { |list_entry| ListImports::ListEntry.new list_entry.symbolize_keys }
      .sort_by(&:target_title)
  end
end
