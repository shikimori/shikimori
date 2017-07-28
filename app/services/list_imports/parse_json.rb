class ListImports::ParseJson
  method_object :json

  def call
    data.map do |list_entry_data|
      ListImports::ListEntry.new list_entry_data
    end
  end

private

  def data
    JSON.parse @json, symbolize_names: true
  end
end
