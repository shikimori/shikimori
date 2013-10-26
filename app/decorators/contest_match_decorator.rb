class ContestMatchDecorator < Draper::Decorator
  delegate_all

  def show_cache_key
    ['contests/match', object, object.voted_for, h.russian_names_key]
  end

  def left_percent
    if (left_votes + right_votes).zero?
      0
    elsif right_id.nil?
      100
    else
      ((left_votes.to_f / (left_votes + right_votes)) * 1000).floor.to_f / 10
    end
  end

  def right_percent
    if (left_votes + right_votes).zero?
      0
    elsif right_id.nil?
      0
    else
      ((right_votes.to_f / (left_votes + right_votes)) * 1000).floor.to_f / 10
    end
  end

  def state_with_voted
    if started?
      voted? ? 'voted' : 'pending'
    elsif finished?
      'finished'
    else
      'created'
    end
  end

  def status member_id
    if created?
      :created
    elsif started?
      :started
    elsif winner_id == member_id
      :winner
    else
      :loser
    end
  end

  def voted_for_class
    voted_for.present? ? "voted-#{voted_for}" : nil
  end
end
