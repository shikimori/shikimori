# frozen_string_literal: true

class Critique::Create
  method_object :params

  def call
    Critique.transaction do
      critique = Critique.new @params
      critique.generate_topic if critique.save
      critique
    end
  end
end
