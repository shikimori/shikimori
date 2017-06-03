class Elasticsearch::Data::Character < Elasticsearch::Data::DataBase
  FIELDS = %i[fullname russian japanese]
  TRACKED_FIELDS = FIELDS

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
