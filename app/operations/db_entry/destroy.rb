class DbEntry::Destroy
  method_object :entry

  def call
    user_ids = related_user_ids

    ActiveRecord::Base.transaction do
      user_rates.delete_all
      user_rate_logs.delete_all
      user_history.delete_all

      User.where(id: user_ids).update_all rate_at: Time.zone.now

      @entry.destroy!
    end
  end

private

  def related_user_ids
    (
      user_rates.distinct.pluck(:user_id) +
        user_rate_logs.distinct.pluck(:user_id) +
        user_history.distinct.pluck(:user_id)
    ).uniq
  end

  def user_rates
    UserRate.where(target: @entry)
  end

  def user_rate_logs
    UserRateLog.where(target: @entry)
  end

  def user_history
    UserHistory.where((@entry.anime? ? :anime_id : :manga_id) => @entry.id)
  end
end
