class Elasticsearch::Data::User < Elasticsearch::Data::DataBase
  NAMES = %i(nickname)
  ALL_FIELDS = NAMES

private

  def nickname
    fix @entry.nickname
  end
end
