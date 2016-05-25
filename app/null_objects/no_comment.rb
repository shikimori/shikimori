# frozen_string_literal: true

class NoComment < NullObject
  rattr_initialize :id

private

  def base_klass
    Comment
  end
end
