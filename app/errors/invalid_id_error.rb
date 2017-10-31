class InvalidIdError < RuntimeError
  def initialize url
    super "invalid id for #{url}"
  end
end
