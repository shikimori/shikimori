# frozen_string_literal: true

class NoMessage < NullObject
  rattr_initialize :id

private

  def base_klass
    Message
  end
end
