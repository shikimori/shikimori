class Elasticsearch::Data::Person < Elasticsearch::Data::DataBase
  text_search_fields %i[name russian japanese]
  data_fields %i[is_seyu is_producer is_mangaka]
  track_changes_fields text_search_fields

private

  def name
    fix @entry.name
  end

  def russian
    fix @entry.russian
  end

  def japanese
    fix @entry.japanese
  end

  def is_seyu
    @entry.seyu
  end

  def is_producer
    @entry.producer
  end

  def is_mangaka
    @entry.mangaka
  end
end
