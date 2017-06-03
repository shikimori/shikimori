class Elasticsearch::Data::Anime < Elasticsearch::Data::DataBase
  DEFAULT_OLD_SCORE = 5
  DEFAULT_NEW_SCORE = 7.5

  KINDS = {
    tv: 10,
    movie: 10,
    ova: 9,
    ona: 9,
    special: 8,
    music: 7
  }
  text_search_fields %i[
    name russian english japanese
    synonym_0 synonym_1 synonym_2 synonym_3 synonym_4 synonym_5
  ]
  data_fields %i[weight]
  track_changes_fields %i[name russian english japanese synonyms score kind]

private

  def name
    fix @entry.name
  end

  def russian
    fix @entry.russian
  end

  def english
    fix @entry.english
  end

  def japanese
    fix @entry.japanese
  end

  def synonym_0
    fix @entry.synonyms[0]
  end

  def synonym_1
    fix @entry.synonyms[1]
  end

  def synonym_2
    fix @entry.synonyms[2]
  end

  def synonym_3
    fix @entry.synonyms[3]
  end

  def synonym_4
    fix @entry.synonyms[4]
  end

  def synonym_5
    fix @entry.synonyms[5]
  end

  def weight
    (1 + Math.log10(score) * Math.log10(kind)).round(3)
  end

  def score
    if @entry.score && @entry.score < 9.9 && @entry.score.positive?
      @entry.score
    elsif @entry.year && @entry.year < 1992
      DEFAULT_OLD_SCORE
    else
      DEFAULT_NEW_SCORE
    end
  end

  def kind
    self.class::KINDS[@entry.kind&.to_sym] || 6
  end
end
