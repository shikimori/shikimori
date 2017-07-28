class ListImportView < ViewObjectBase
  pattr_initialize :list_import
  instance_cache :added, :updated, :not_imported

  def added
    output_collection ListImports::ImportList::ADDED
  end

  def updated
    @list_import.output[ListImports::ImportList::UPDATED]
      .sort_by { |list_entry_before, _| list_entry_before['target_title'] }
      .map do |list_entry_before, list_entry_after|
        [
          ListImports::ListEntry.new(list_entry_before.symbolize_keys),
          ListImports::ListEntry.new(list_entry_after.symbolize_keys)
        ]
      end
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
