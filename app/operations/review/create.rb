class Review::Create
  method_object :params

  def call
    Review.create @params
  end
end
