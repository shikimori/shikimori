class GroupRolesQuery
  pattr_initialize :club

  def complete phrase
    unescaped_phrase = SearchHelper.unescape phrase
    club
      .members
      .where("nickname = ? or nickname ilike ?", unescaped_phrase, "#{unescaped_phrase}%")
      .order(:nickname)
      .to_a
  end
end
