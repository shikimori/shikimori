class Review::Create
  method_object :params

  def call
    Review.transaction do
      review = Review.new @params
      review.generate_topic if review.save
      review
    end
  end
end
