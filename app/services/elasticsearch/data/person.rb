class Elasticsearch::Data::Person < Elasticsearch::Data::DataBase
  NAMES = %i(name russian japanese)

  def call
    super.merge(
      is_seyu: @entry.seyu,
      is_producer: @entry.producer,
      is_mangaka: @entry.mangaka
    )
  end

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
end
