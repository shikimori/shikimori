class ContestMatchDecorator < BaseDecorator
  instance_cache :left, :right

  def left
    object.left&.decorate
  end

  def right
    object.right&.decorate
  end

  def left_percent
    if (left_votes + right_votes).zero?
      0
    elsif right_id.nil?
      100
    else
      ((left_votes.to_f / (left_votes + right_votes)) * 100).floor(1)
    end
  end

  def right_percent
    if (left_votes + right_votes).zero?
      0
    elsif right_id.nil?
      0
    else
      ((right_votes.to_f / (left_votes + right_votes)) * 100).floor(1)
    end
  end

  def status member_id
    if draw?
      :draw
    elsif created?
      :created
    elsif started?
      :started
    elsif winner_id == member_id
      :winner
    else
      :loser
    end
  end

  def defeated_by entry, round
    return [] unless entry

    @defeated ||= {}
    @defeated["#{entry.id}-#{round.id}"] ||= contest
      .defeated_by(entry, round)
      .map(&:decorate)
  end
end
