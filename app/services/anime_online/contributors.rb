class AnimeOnline::Contributors
  UPLOAD_SCORE = 10
  BROKEN_SCORE = 1
  WRONG_SCORE = 1

  method_object %i[limit! is_adult!]

  def call
    scope = reports_scope %i[broken wrong uploaded]

    if @is_adult == true
      scope.joins! anime_video: :anime
      scope.where! AnimeVideo::XPLAY_CONDITION

    elsif @is_adult == false
      scope.joins! anime_video: :anime
      scope.where! AnimeVideo::PLAY_CONDITION
    end

    scope.map(&:user)
  end

private

  def reports_scope kinds
    AnimeVideoReport
      .includes(:user)
      .select(:user_id, select_sql)
      .where(state: :accepted, kind: kinds)
      .where.not(user_id: User::GUEST_ID)
      .group(:user_id)
      .order(Arel.sql('score desc'))
      .limit(@limit)
  end

  def select_sql
    <<-SQL.squish
      sum(
        case
          when #{AnimeVideoReport.table_name}.kind='uploaded'
            then #{UPLOAD_SCORE}
          when #{AnimeVideoReport.table_name}.kind='broken'
            then #{BROKEN_SCORE}
          when #{AnimeVideoReport.table_name}.kind='wrong'
            then #{WRONG_SCORE}
          else 0
        end
      ) as score
    SQL
  end
end
