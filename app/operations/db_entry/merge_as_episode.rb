class DbEntry::MergeAsEpisode < DbEntry::MergeIntoOther
  method_object %i[entry! other! as_episode! episode_field!]

  ASSIGN_FIELDS = []
  MERGE_FIELDS = %i[
    coub_tags
    fansubbers
    fandubbers
  ]

private

  def merge_user_rates
    other_rates = @other.rates.to_a

    @entry.rates.each do |entry_rate|
      merge_rate entry_rate, other_rates
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

  def merge_rate entry_rate, other_rates
    return if entry_rate.send(@episode_field).zero?

    user_id = entry_rate.user_id

    other_rate = other_rates.find { |v| v.user_id == user_id }
    new_value = @as_episode + entry_rate.send(@episode_field) - 1

    if other_rate
      other_rate.update!(
        @episode_field => [other_rate.send(@episode_field), new_value].max
      )
    else
      create_rate entry_rate, new_value
    end
  rescue ActiveRecord::RecordInvalid
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
