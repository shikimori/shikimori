class AnimeVideoPreviewDecorator < Draper::Decorator
  include Translation
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
      t 'excellent'
    elsif object.score >= 6
      t 'good'
    else
      t 'okay'
    end
  end
end

