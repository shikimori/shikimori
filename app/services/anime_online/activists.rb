class AnimeOnline::Activists
  ENOUGH_TO_TRUST_RUTUBE = 10

  class << self
    def rutube_responsible
      @rutube_responsible ||= resposible_users("rutube.ru")
    end

    def can_trust? user_id, hosting
      case hosting
        when 'rutube.ru' then rutube_responsible.include?(user_id)
      end
    end

    def reset
      @rutube_responsible = nil
    end

  private
    def resposible_users hosting
      active_users = AnimeVideoReport
        .select(:user_id, "count(*) as videos")
        .joins(:anime_video)
        .where(kind: :broken)
        .where("url like 'http://#{hosting}%'")
        .group(:user_id)
        .having("count(*) >= ?", ENOUGH_TO_TRUST_RUTUBE)
        .map(&:user_id)

      user_with_rejected = AnimeVideoReport
        .where(kind: :broken, state: :rejected)
        .where(user_id: active_users)
        .map(&:user_id)

      active_users - user_with_rejected
    end
  end
end
