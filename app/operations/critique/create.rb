# frozen_string_literal: true

class Critique::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    review = Critique.new params
    review.locale = locale

    review.generate_topics locale if review.save
    review
  end
end
