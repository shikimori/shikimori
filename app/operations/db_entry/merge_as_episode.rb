class DbEntry::MergeAsEpisode < DbEntry::MergeIntoOther
  method_object %i[entry! other! as_episode! episode_field!]

  RELATIONS = DbEntry::MergeIntoOther::RELATIONS - %i[
    collection_links
    club_links
  ]

  ASSIGN_FIELDS = []
  MERGE_FIELDS = %i[
    coub_tags
    fansubbers
    fandubbers
  ]
  EPISODE_LABEL = {
    episodes: 'Ep.',
    volumes: 'Vol.',
    chapters: 'Chap.'
  }

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
    entry_rate_value = corrected_enty_rate_value entry_rate
    return if entry_rate_value.zero?

    user_id = entry_rate.user_id

    other_rate = other_rates.find { |v| v.user_id == user_id }
    new_value = @as_episode + entry_rate_value - 1

    if other_rate
      update_rate other_rate, new_value
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
      @episode_field => @as_episode == 1 ? new_value : 0,
      status: new_value == @other.send(@episode_field) ?
        Types::UserRate::Status[:completed] :
        other_new_status,
      text: merge_note(new_value)
    )
  end

  def update_rate other_rate, new_value
    other_value = other_rate.send @episode_field

    return if other_value >= new_value

    new_text = (other_rate.text + "\n" + merge_note(new_value)).strip

    if @as_episode == 1 || other_value == @as_episode - 1 || other_value >= @as_episode
      other_rate.update! @episode_field => new_value, text: new_text
    else
      other_rate.update! text: new_text
    end
  end

  def corrected_enty_rate_value entry_rate
    value = entry_rate.send @episode_field

    if value.zero? && entry_rate.completed?
      [@entry.send(@episode_field), 1].max
    else
      value
    end
  end

  def merge_note new_value
    "✅ #{EPISODE_LABEL[@episode_field]} #{[@as_episode, new_value].uniq.join('-')} " +
      + @entry.name + (@entry.russian.present? ? " (#{@entry.russian})" : '')
  end
end
