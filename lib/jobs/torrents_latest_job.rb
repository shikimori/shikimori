require Rails.root.join('lib', 'rake_tasks')

class TorrentsLatestJob
  def perform
    TorrentsTasks.new.latest
  end
end
