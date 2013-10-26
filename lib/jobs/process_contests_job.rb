class ProcessContestsJob
  def perform
    Contest.where(state: 'started').each(&:process!)
  end
end
