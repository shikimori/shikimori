class AnimeOnline::ResponsibleUploaders
  method_object

  UPLOADS_TO_TRUST = 50
  TRUST_THRESHOLD = 0.95

  def call
    active_users
      .select do |user_id, uploads_count|
        errors_count = (rejected_uploads[user_id] || 0) + (complaints_on_user[user_id] || 0)

        1 - errors_count * 1.0 / uploads_count >= TRUST_THRESHOLD
      end
      .map(&:first)
  end

private

  def active_users
    @active_users ||= user_uploads_scope
      .select(:user_id, 'count(*) as videos')
      .group(:user_id)
      .having('count(*) >= ?', UPLOADS_TO_TRUST)
      .select('user_id, count(*) as uploads')
      .each_with_object({}) { |v, memo| memo[v.user_id] = v.uploads }
  end

  def rejected_uploads
    @user_with_rejects ||= user_uploads_scope
      .where(state: :rejected)
      .where(user_id: active_users_ids)
      .group(:user_id)
      .select('user_id, count(*) as rejects')
      .each_with_object({}) { |v, memo| memo[v.user_id] = v.rejects }
  end

  def complaints_on_user
    @complaints_on_user ||= AnimeVideoReport
      .where(kind: %i[wrong other])
      .where(state: :accepted)
      .where(anime_video_id: active_users_uploads.select(:anime_video_id))
      .joins(:anime_video)
      .joins(
        <<-SQL
          left join anime_video_reports av
            on av.anime_video_id=anime_videos.id
            and av.kind = 'uploaded'
        SQL
      )
      .group('av.user_id')
      .select('av.user_id, count(*) as complaints')
      .each_with_object({}) { |v, memo| memo[v.user_id] = v.complaints }
  end

  def active_users_ids
    active_users.map(&:first)
  end

  def user_uploads_scope
    AnimeVideoReport.where(kind: :uploaded)
  end

  def active_users_uploads
    user_uploads_scope
      .where(user_id: active_users_ids)
      .where(state: :accepted)
  end
end
