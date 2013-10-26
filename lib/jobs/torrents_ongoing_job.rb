require Rails.root.join('lib', 'rake_tasks')

class TorrentsOngoingJob
  def perform
    TorrentsTasks.new.ongoing
  end
end
