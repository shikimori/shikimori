class AnimeVideoPreviewDecorator < Draper::Decorator
  delegate_all

  def name
    if russian
      "#{object.russian} / #{object.name}"
    else
      object.name
    end
  end

  def description
    if object.description_html.blank?
      h.format_html_text object.description_mal
    else
      object.description_html
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
end

