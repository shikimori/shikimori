class Topics::NewsTopic < Topic
  enumerize :action,
    in: [:anons, :ongoing, :released, :episode],
    predicates: true

  def title
    return super unless generated?

    if episode?
      "#{action_text} #{value}".capitalize
    else
      action_text.capitalize
    end
  end
end
