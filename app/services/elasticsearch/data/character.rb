class Elasticsearch::Data::Character < Elasticsearch::Data::DataBase
  name_fields %i[fullname russian japanese]
  data_fields %i[]
  track_changes_fields NAME_FIELDS

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
