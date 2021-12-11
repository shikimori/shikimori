class Review::Destroy
  method_object :review, :faye

  def call
    changelog
    @faye.destroy @review
  end

private

  def changelog
    NamedLogger.changelog.info(
      user_id: @faye.actor&.id,
      action: :destroy,
      review: @review.attributes
    )
  end
end
