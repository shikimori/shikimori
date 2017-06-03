class Elasticsearch::Data::Collection < Elasticsearch::Data::DataBase
  FIELDS = %i[name locale]
  TRACKED_FIELDS = FIELDS

private

  def name
    fix @entry.name
  end

  def locale
    @entry.locale
  end
end
