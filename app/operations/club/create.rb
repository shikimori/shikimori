# frozen_string_literal: true

class Club::Create < ServiceObjectBase
  pattr_initialize :params

  def call
    Club.transaction do
      club = Club.new @params
      club.generate_topic if club.save
      club
    end
  end
end
