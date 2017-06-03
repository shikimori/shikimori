class Elasticsearch::Data::User < Elasticsearch::Data::DataBase
  FIELDS = %i[nickname]
  TRACKED_FIELDS = FIELDS

private

  def nickname
    fix @entry.nickname
  end
end
