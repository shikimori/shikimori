class Elasticsearch::Data::Person < Elasticsearch::Data::DataBase
  FIELDS = %i[name russian japanese is_seyu is_producer is_mangaka]
  TRACKED_FIELDS = FIELDS

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
