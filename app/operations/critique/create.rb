# frozen_string_literal: true

class Critique::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    Critique.transaction do
      critique = Critique.new @params
      critique.locale = @locale

      critique.generate_topics @locale if critique.save
      critique
    end
  end
end
