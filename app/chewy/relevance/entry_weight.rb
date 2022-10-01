# NOTE: not used anymore
class Relevance::EntryWeight
  method_object :entry

  OLD_YEAR = 1992

  DEFAULT_OLD_SCORE = 5
  DEFAULT_NEW_SCORE = 7.5

  KIND_WEIGHT = {
    tv: 10,
    movie: 10,
    ova: 9,
    ona: 9,
    special: 8,
    music: 7,

    manga: 10,
    manhwa: 10,
    manhua: 10,
    novel: 10,
    doujin: 8,
    one_shot: 7
  }

  DEFAULT_WEIGHT = 6

  def call
    (
      1 + (
        Math.log10(score_value(@entry)) *
          Math.log10(kind_value(@entry)) *
          censored_value(@entry)
      )
    ).round(3)
  end

private

  def score_value entry
    if entry.score && entry.score < 9.9 && entry.score.positive?
      [entry.score, 2].max
    elsif entry.year && entry.year < OLD_YEAR
      DEFAULT_OLD_SCORE
    else
      DEFAULT_NEW_SCORE
    end
  end

  def kind_value entry
    KIND_WEIGHT[entry.kind&.to_sym] || DEFAULT_WEIGHT
  end

  def censored_value entry
    entry.censored? ? 0.5 : 1
  end
end
