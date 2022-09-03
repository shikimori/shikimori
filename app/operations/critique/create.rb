# frozen_string_literal: true

class Critique::Create < ServiceObjectBase
  pattr_initialize :params

  def call
    Critique.transaction do
      critique = Critique.new @params
      critique.generate_topics if critique.save
      critique
    end
  end
end
