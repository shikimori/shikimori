class InvalidId < Exception
  def initialize(url)
    super("invalid id for #{url}")
  end
end
