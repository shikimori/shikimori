class Club::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    club = Club.new params
    club.locale = locale

    if club.save
      club.generate_topics locale
    end

    club
  end
end
