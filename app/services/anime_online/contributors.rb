class AnimeOnline::Contributors
  UPLOAD_SCORE = 10
  BROKEN_SCORE = 1
  WRONG_SCORE = 1

  class << self
    def top limit=20, is_adult=nil
      group_reports_by_kind([:broken, :wrong, :uploaded], limit, is_adult)
        .map(&:user)
    end

    # FIX : можно будет удалить после перехода с Uploaders на Contributors
    def uploaders_top limit=20, is_adult=nil
      group_reports_by_kind(:uploaded, limit, is_adult).map(&:user)
    end

    private

    def group_reports_by_kind kinds, limit, is_adult
      query = AnimeVideoReport
        .includes(:user)
        .select(
          :user_id,
          "sum(case when #{AnimeVideoReport.table_name}.kind='uploaded' then #{UPLOAD_SCORE} when #{AnimeVideoReport.table_name}.kind='broken' then #{BROKEN_SCORE} when #{AnimeVideoReport.table_name}.kind='wrong' then #{WRONG_SCORE} else 0 end) as score")
        .where(state: :accepted, kind: kinds)
        .where.not(user_id: User::GuestID)
        .group(:user_id)
        .order('score desc')
        .limit(limit)

      if is_adult == true
        query.joins! anime_video: :anime
        query.where! AnimeVideo::XPLAY_CONDITION
      elsif is_adult == false
        query.joins! anime_video: :anime
        query.where! AnimeVideo::PLAY_CONDITION
      end

      query
    end

    def score kinds
      1
    end
  end
end
