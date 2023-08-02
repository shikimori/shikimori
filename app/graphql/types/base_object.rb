# frozen_string_literal: true

class Types::BaseObject < GraphQL::Schema::Object
  def current_user
    context[:current_user]
  end

  def request
    context[:request]
  end
end
