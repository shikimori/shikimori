class Elasticsearch::Data::Club < Elasticsearch::Data::DataBase
  text_search_fields %i[name locale]
  data_fields %i[]
  track_changes_fields text_search_fields

private

  def name
    fix @entry.name
  end

  def locale
    @entry.locale
  end
end
