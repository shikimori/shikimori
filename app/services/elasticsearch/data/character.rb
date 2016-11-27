class Elasticsearch::Data::Character < Elasticsearch::Data::DataBase
  NAMES = %i(fullname russian japanese)

private

  def fullname
    fix @entry.fullname
  end

  def russian
    fix @entry.russian
  end

  def japanese
    fix @entry.japanese
  end
end
