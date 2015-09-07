class Moderation::VersionsItemTypeQuery
  pattr_initialize :type

  def result
    case type.try :to_sym
      when :anime_video
        Version.where(item_type: AnimeVideo.name)

      when :content
        Version.where.not(item_type: AnimeVideo.name)

      else raise ArgumentError, "unknown type: #{type}"
    end
  end
end
