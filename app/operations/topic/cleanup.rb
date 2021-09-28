class Topic::Cleanup
  method_object :topic

  COMMENTS_OFFSET = 1_000
  COMMENT_LIVE_TIME = 6.months
  IGNORED_TOPIC_IDS = [
    177_854, # achievements club topics
    247_360, 323_701, 276_032, 227_430, 227_426, 227_420, 227_422, 227_431, 227_416, 227_432,
    227_427, 271_672, 222_059, 222_068, 222_044, 222_645, 227_429, 227_425, 271_370, 222_061,
    222_047, 222_067, 227_419, 245_150, 248_176, 222_041, 222_065, 222_037, 227_423, 222_036,
    227_424, 222_064, 227_417, 222_038, 227_421, 247_398, 222_051, 227_428, 310_322, 254_400,
    254_401, 222_056, 227_418, 248_585, 222_035, 222_063, 245_151
  ]

  def call
    return if IGNORED_TOPIC_IDS.include? @topic.id
    return if @topic.comments_count <= COMMENTS_OFFSET

    comments(@topic).find_each do |comment|
      next if comment.created_at > COMMENT_LIVE_TIME.ago

      Comment::Cleanup.call comment
    end
  end

private

  def comments topic
    topic
      .comments
      .where('id < ?', offset_comment(topic).id)
      .except(:order)
  end

  def offset_comment topic
    topic
      .comments
      .except(:order)
      .order(id: :desc)
      .offset(COMMENTS_OFFSET - 1)
      .limit(1)
      .to_a
      .first
  end
end
