class DbEntry::MergeAsEpisode < DbEntry::MergeIntoOther
  method_object %i[entry! other! episode!]

private

  def merge_user_rates
    other_rates = @other.rates.to_a

    @entry.rates.each do |_user_rate|
    #   user_id = user_rate.user_id
    #
    #   if user_rate.completed?
    #     other_rate = other_rates.find { |v| v.user_id == user_id }
    #
    #     if other_rate
    #       next if other_rate.completed?
    #
    #       cleanup_user_rate other_rate
    #     end
    #   end
    #
    #   user_rate.update! target: @other
    #
    #   update_user_rate_logs user_id
    #   update_user_history user_id
    rescue ActiveRecord::RecordInvalid
    end

    delete_user_rates
    delete_user_rate_logs
    delete_user_histories
  end

  def delete_user_rates
    @entry.rates.delete_all
  end

  def delete_user_rate_logs
    UserRateLog.where(target: @entry).delete_all
  end

  def delete_user_histories
    UserHistory.where(target: @entry).delete_all
  end
end
