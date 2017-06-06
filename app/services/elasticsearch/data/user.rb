class Elasticsearch::Data::User < Elasticsearch::Data::DataBase
  name_fields %i[nickname]
  data_fields %i[]
  track_changes_fields NAME_FIELDS

private

  def nickname
    fix @entry.nickname
  end
end
