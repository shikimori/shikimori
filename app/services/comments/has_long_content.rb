class Comments::HasLongContent
  method_object :comment

  def call
    @comment.body.size > 500 ||
      @comment.body.include?('[img') ||
      @comment.body.include?('[imag') ||
      @comment.body.include?('[poster') ||
      @comment.body.count("\n") > 5
  end
end
