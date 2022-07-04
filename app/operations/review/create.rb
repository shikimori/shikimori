class Review::Create
  method_object :params

  def call
    Review.transaction do
      review = Review.new @params
      review.generate_topics review.locale if review.save
      review
    end
  end
end
