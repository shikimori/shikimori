class Comment::ContentPolicy
  static_facade :check_height?, :comment

  def check_height?
    @comment.persisted? && (
      @comment.body.size > 500 ||
      @comment.body.include?('[img') ||
      @comment.body.include?('[imag') ||
      @comment.body.include?('[poster') ||
      @comment.body.count("\n") > 5
    )
  end
end
