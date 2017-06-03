class Elasticsearch::Data::Character < Elasticsearch::Data::DataBase
  text_search_fields %i[fullname russian japanese]
  data_fields %i[]
  track_changes_fields text_search_fields

private

  def fullname
    fix @entry.fullname
  end

  def russian
    fix @entry.russian
  end

  def japanese
    fix @entry.japanese
  end
end
