class Elasticsearch::Data::Club < Elasticsearch::Data::DataBase
  name_fields %i[name]
  data_fields %i[locale]
  track_changes_fields NAME_FIELDS

private

  def name
    fix @entry.name
  end

  def locale
    @entry.locale
  end
end
