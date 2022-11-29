# frozen_string_literal: true

class Club::Create
  method_object :params

  def call
    Club.transaction do
      club = Club.new @params
      club.generate_topic if club.save
      club
    end
  end
end
