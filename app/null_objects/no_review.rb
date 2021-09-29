# frozen_string_literal: true

class NoReview < NullObject
  rattr_initialize :id

private

  def base_klass
    Review
  end
end
