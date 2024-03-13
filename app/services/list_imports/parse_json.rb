class ListImports::ParseJson
  method_object :json

  def call
    data.map do |list_entry_data|
      ListImports::ListEntry.new(
        **list_entry_data,
        status: parse_status(list_entry_data[:status])
      )
    end
  end

private

  def data
    JSON.parse @json, symbolize_names: true
  end

  def parse_status status
    return ListImports::ListEntry::StatusWithUnknown[:unknown] if status.blank?

    ListImports::ListEntry::StatusWithUnknown[status]
  rescue Dry::Types::CoercionError
    ListImports::ListEntry::StatusWithUnknown[:unknown]
  end
end
