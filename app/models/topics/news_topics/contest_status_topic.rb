class Topics::NewsTopics::ContestStatusTopic < Topics::NewsTopic
  include Translation

  enumerize :action,
    in: Types::Topic::ContestStatusTopic::Action.values,
    predicates: true

  CONTEST_IMAGE_V1 = 1_316_293
  CONTEST_IMAGE_V2 = 2_550_745
  CONTEST_IMAGE_V3 = 2_551_412

  def title
    i18n_t "title.#{action}"
  end

  def full_title
    "#{title} #{linked.title}"
  end

  def body
    "[wall][wall_image=#{CONTEST_IMAGE_V3}][/wall]"
  end
end
