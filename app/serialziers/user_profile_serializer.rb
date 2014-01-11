class UserProfileSerializer < UserSerializer
  attributes :name, :sex, :full_years, :last_online, :last_online_at, :website, :location, :last_online_at
  attributes :banned?, :about, :about_html, :common_info, :last_online

  attributes :anime_statuses
  attributes :manga_statuses

  def anime_statuses
    object.stats[:anime_statuses]
  end

  def manga_statuses
    object.stats[:manga_statuses]
  end
end
