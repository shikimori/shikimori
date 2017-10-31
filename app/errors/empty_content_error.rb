class EmptyContentError < StandardError
  def initialize url
    super "can't get content for \"#{url}\""
  end
end
