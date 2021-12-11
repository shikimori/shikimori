class Topic::Destroy
  method_object :topic, :faye

  def call
    @faye.destroy @topic
  end
end
