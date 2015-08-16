class AnimeVideoPreviewDecorator < BaseDecorator
  def name
    if object.russian && I18n.russian?
      "#{object.russian} / #{object.name}"
    else
      object.name
    end
  end

  def episodes
    object.episodes.to_i
  end

  def duration
    object.duration.to_i
  end

  def rating
    object.rating if object.rating and object.rating != 'None'
  end

  def score
    if object.score >= 8
      i18n_t 'score.excellent'
    elsif object.score >= 6
      i18n_t 'score.good'
    else
      i18n_t 'score.okay'
    end
  end
end

