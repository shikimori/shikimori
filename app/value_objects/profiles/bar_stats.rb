class Profiles::BarStats
  include ShallowAttributes

  attribute :type, String
  attribute :lists_stats, Array, of: Profiles::ListStats

  def any?
    total.positive?
  end

  def total
    @total ||= lists_stats.sum(&:size)
  end

  def completed
    @completed ||= by_status(:completed).sum(&:size)
  end

  def dropped
    @dropped ||= by_status(:dropped).sum(&:size)
  end

  def incompleted
    total - completed - dropped
  end

  def completed_percent
    (completed * 100.0 / total).round 2
  end

  def dropped_percent
    100 - completed_percent - incompleted_percent
  end

  def incompleted_percent
    (incompleted * 100.0 / total).round 2
  end

  private

  def by_status status
    lists_stats.select { |stat| stat.id == UserRate.statuses[status] }
  end
end
