class Elasticsearch::Data::User < Elasticsearch::Data::DataBase
  NAMES = %i(nickname)

private

  def nickname
    fix @entry.nickname
  end
end
