class Moderation::VersionsItemTypeQuery
  method_object :type

  Types = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:content, :anime_video, :role)

  def call
    case Types[type]
      when Types[:content]
        Version
          .where('type is null or type != ?', Versions::RoleVersion.name)
          .where.not(item_type: AnimeVideo.name)

      when Types[:anime_video]
        Version
          .where('type is null or type != ?', Versions::RoleVersion.name)
          .where(item_type: AnimeVideo.name)

      when Types[:role]
        Version
          .where(type: Versions::RoleVersion.name)
    end
  end
end
