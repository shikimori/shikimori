class Review::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    review = Review.new params
    review.locale = locale

    if review.save
      review.generate_topics locale
    end

    review
  end
end
