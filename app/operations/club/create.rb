# frozen_string_literal: true

class Club::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    club = Club.new params
    club.locale = locale

    club.generate_topics locale if club.save
    club
  end
end
