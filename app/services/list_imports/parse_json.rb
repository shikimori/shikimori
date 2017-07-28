class ListImports::ParseJson
  method_object :json

  def call
    data.map do |list_entry_data|
      build(parse(list_entry_data))
    end
  end

private

  def build list_entry_data
    ListImports::ListEntry.new({
      episodes: 0,
      volumes: 0,
      chapters: 0
    }.merge(list_entry_data))
  end

  def parse list_entry_data
    { episodes: 0, volumes: 0, chapters: 0 }.merge list_entry_data
  end

  def data
    JSON.parse @json, symbolize_names: true
  end
end
