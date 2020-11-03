class ClubRolesQuery
  pattr_initialize :club

  def complete phrase
    club
      .members
      .where('nickname = ? or nickname ilike ?', phrase, "#{phrase}%")
      .order(:nickname)
      .to_a
  end
end
