class Elasticsearch::Data::Collection < Elasticsearch::Data::DataBase
  text_search_fields %i[name]
  data_fields %i[locale]
  track_changes_fields TEXT_SEARCH_FIELDS

private

  def name
    fix @entry.name
  end

  def locale
    @entry.locale
  end
end
