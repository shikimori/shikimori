class Neko::Apply
  method_object :user, %i[added updated removed]

  def call
    return if not_changed? @added, @updated, @removed

    Achievement.transaction do
      import(@added + @updated) if @added.any? || @updated.any?
      delete(@removed) if @removed.any?

      @user.touch
    end

    publish @user, @added, @removed
  end

private

  def not_changed? added, updated, removed
    added.none? && updated.none? && removed.none?
  end

  def import achievements
    Achievement.import(
      achievements.map { |achievement| build achievement },
      on_duplicate_key_update: {
        conflict_target: %i[user_id neko_id level],
        columns: %i[progress]
      }
    )
  end

  def build achievement
    Achievement.new(
      user_id: achievement.user_id,
      neko_id: achievement.neko_id,
      level: achievement.level,
      progress: achievement.progress
    )
  end

  def delete achievements
    Achievement
      .where(delete_achievements_sql(achievements))
      .delete_all
  end

  def delete_achievements_sql achievements
    achievements
      .map { |achievement| delete_achievement_sql(achievement) }
      .join(' or ')
  end

  def delete_achievement_sql achievement
    <<-SQL
      (
        user_id=#{ApplicationRecord.sanitize achievement.user_id}
        and neko_id=#{ApplicationRecord.sanitize achievement.neko_id}
        and level=#{ApplicationRecord.sanitize achievement.level}
      )
    SQL
  end

  def publish user, added, removed
    unless !Rails.env.production? ||
        Users::AchievementsController::ACHIEVEMENTS_CLUB_USER_IDS.include?(user.id)
      return
    end

    publish_faye added, :gained, user if added.any?
    publish_faye removed, :lost, user if removed.any?
  end

  def publish_faye achievements_data, event, user
    achievements = achievements_data.map do |achivement_data|
      {
        neko_id: achivement_data[:neko_id],
        label: I18n.t("achievements.neko_name.#{achivement_data[:neko_id]}")
      }
    end

    faye_publisher.publish_achievements achievements, event, user.faye_channel
  end

  def faye_publisher
    @faye_publisher ||= FayePublisher.new(nil, nil)
  end
end
