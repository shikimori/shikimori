# frozen_string_literal: true

class Review::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    review = Review.new params
    review.locale = locale

    review.generate_topics locale if review.save
    review
  end
end
