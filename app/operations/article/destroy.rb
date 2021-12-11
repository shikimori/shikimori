class Article::Destroy
  method_object :article, :actor

  def call
    changelog
    @article.destroy
  end

private

  def changelog
    NamedLogger.changelog.info(
      user_id: @actor.id,
      action: :destroy,
      article: @article.attributes
    )
  end
end
