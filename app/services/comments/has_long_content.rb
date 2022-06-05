class Comments::HasLongContent
  method_object :comment

  def call
    (comment.body.size > 500 ||
      comment.body.include?('[poster') ||
      comment.body =~ /\[ima?g/ ||
      comment.body.count("\n") > 5
    ) ? true : false # important to not return size causing bugs in height shortener
  end
end
