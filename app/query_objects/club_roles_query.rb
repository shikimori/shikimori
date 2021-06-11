class ClubRolesQuery
  pattr_initialize :club

  IDS_LIMIT = 10

  def complete phrase
    searched_users = Search::User.call(
      scope: User.where(id: club.members),
      phrase: phrase,
      ids_limit: IDS_LIMIT
    )

    club
      .members
      .where(id: searched_users)
      .order(:nickname)
      .to_a
  end
end
