class AnimeVideoPreviewDecorator < Draper::Decorator
  delegate_all

  def name
    if russian
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
      'отлично'
    elsif object.score >= 6
      'хорошо'
    else
      'нормально'
    end
  end
end

