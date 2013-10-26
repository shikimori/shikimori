class ServerUnavailable < Exception
  def initialize(url)
    super("server didn't respond for #{url}")
  end
end
