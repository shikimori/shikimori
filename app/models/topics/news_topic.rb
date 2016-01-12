class Topics::NewsTopic < Topic
  enumerize :action,
    in: [:anons, :ongoing, :released, :episode],
    predicates: true

  # def title
    # return super unless generated?
  # end

  # def body
    # return super unless generated?
  # end
end
