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

  def empty_list_error?
    @list_import.failed? &&
      @list_import.output&.dig('error', 'type') == ListImport::ERROR_EMPTY_LIST
  end

  def broken_file_error?
    @list_import.failed? &&
      @list_import.output&.dig('error', 'type') == ListImport::ERROR_BROKEN_FILE
  end

  def mismatched_list_type_error?
    @list_import.failed? &&
      @list_import.output&.dig('error', 'type') == ListImport::ERROR_MISMATCHED_LIST_TYPE
  end

  def missing_fields_error?
    @list_import.failed? &&
      @list_import.output&.dig('error', 'type') == ListImport::ERROR_MISSING_FIELDS
  end

  def missing_fields
    @list_import.output['error']['fields']
  end

  def list_diff list_entry_before, list_entry_after
    html_before = render_to_string(
      partial: 'users/list_imports/list_entry_details',
      locals: { list_entry: list_entry_before }
    )
    html_after = render_to_string(
      partial: 'users/list_imports/list_entry_details',
      locals: { list_entry: list_entry_after }
    )

    HTMLDiff.diff(html_before, html_after).html_safe
  end

private

  def output_collection key
    @list_import.output[key]
      .map { |list_entry| ListImports::ListEntry.new list_entry.symbolize_keys }
      .sort_by(&:target_title)
  end

  def render_to_string *args
    h.controller.render_to_string(*args)
  end
end
