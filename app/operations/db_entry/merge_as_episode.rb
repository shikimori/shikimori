class DbEntry::MergeAsEpisode < DbEntry::MergeIntoOther
  method_object %i[entry! other! episode! episode_field!]

  ASSIGN_FIELDS = []
  MERGE_FIELDS = []

private

  def merge_user_rates
    other_rates = @other.rates.to_a

    @entry.rates.each do |entry_rate|
      next if entry_rate.send(@episode_field).zero?

      user_id = entry_rate.user_id

      other_rate = other_rates.find { |v| v.user_id == user_id }
      new_value = @episode + entry_rate.send(@episode_field) - 1

      if other_rate
      else
        create_rate entry_rate, new_value
        # entry_rate.update! target: @other, @episode_field => new_value
      end
      # next if other_rate.
    #   user_id = entry_rate.user_id
    #
    #   if entry_rate.completed?
    #     other_rate = other_rates.find { |v| v.user_id == user_id }
    #
    #     if other_rate
    #       next if other_rate.completed?
    #
    #       cleanup_user_rate other_rate
    #     end
    #   end
    #
    #   entry_rate.update! target: @other
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

  def create_rate entry_rate, new_value
    other_new_status =
      case Types::UserRate::Status[entry_rate.status]
        when Types::UserRate::Status[:on_hold] then Types::UserRate::Status[:on_hold]
        when Types::UserRate::Status[:dropped] then Types::UserRate::Status[:dropped]
        else Types::UserRate::Status[:watching]
      end

    UserRate.create!(
      user_id: entry_rate.user_id,
      target: @other,
      @episode_field => new_value,
      status: new_value == @other.send(@episode_field) ?
        Types::UserRate::Status[:completed] :
        other_new_status
    )
  end
end
