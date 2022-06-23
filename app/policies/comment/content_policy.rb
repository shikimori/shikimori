class Comment::ContentPolicy
  static_facade :check_height?, :comment

  BOUNDARY_BODY_SIZE = 500
  BOUNDARY_NEWLINES_AMOUNT = 6

  def check_height?
    @comment.persisted? && (
      @comment.body.size >= BOUNDARY_BODY_SIZE ||
      @comment.body.include?('[img') ||
      @comment.body.include?('[imag') ||
      @comment.body.include?('[poster') ||
      @comment.body.count("\n") >= BOUNDARY_NEWLINES_AMOUNT
    )
  end
end
