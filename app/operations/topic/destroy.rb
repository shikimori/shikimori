class Topic::Destroy
  method_object :topic, :faye

  def call
    NamedLogger.changelog.info(
      user_id: @faye.actor&.id,
      action: :destroy,
      topic: @topic.attributes
    )

    @faye.destroy @topic
  end
end
