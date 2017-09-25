class Neko::Apply
  method_object :user, %i[added updated removed]

  def call
    return if not_changed? @added, @updated, @removed

    Achievement.transaction do
      import(@user, @added + @updated) if @added.any? || @updated.any?
      delete(@user, @removed) if @removed.any?

      @user.touch
    end
  end

private

  def not_changed? added, updated, removed
    added.none? && updated.none? && removed.none?
  end

  def import user, achievements
    Achievement.import achievements.map { |v| build user, v },
      on_duplicate_key_update: {
        conflict_target: %i[user_id neko_id level],
        columns: %i[progress]
      }
  end

  def build user, achievement
    Achievement.new(
      user: user,
      neko_id: achievement[:neko_id],
      level: achievement[:level],
      progress: achievement[:progress]
    )
  end

  def delete user, achievements
    user.achievements
      .where(delete_achievements_sql(user, achievements))
      .delete_all
  end

  def delete_achievements_sql user, achievements
    achievements
      .map { |achievement| delete_achievement_sql(user, achievement) }
      .join(' or ')
  end

  def delete_achievement_sql user, achievement
    <<-SQL
      (
        user_id=#{ApplicationRecord.sanitize user.id}
        and neko_id=#{ApplicationRecord.sanitize achievement[:neko_id]}
        and level=#{ApplicationRecord.sanitize achievement[:level]}
      )
    SQL
  end
end
