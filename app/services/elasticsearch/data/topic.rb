class Elasticsearch::Data::Topic < Elasticsearch::Data::DataBase
  name_fields %i[name]
  data_fields %i[locale forum_id]
  track_changes_fields %i[name forum_id]

private

  def name
    fix Topics::TopicViewFactory.new(true, true).build(@entry).topic_title
  end

  def locale
    @entry.locale
  end

  def forum_id
    @entry.forum_id
  end
end
