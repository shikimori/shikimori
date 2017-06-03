class Elasticsearch::Data::Collection < Elasticsearch::Data::DataBase
  NAMES = %i(name)
  ALL_FIELDS = NAMES

private

  def nickname
    fix @entry.name
  end
end
