class ForceRedirect < ActionController::RoutingError
  attr_accessor :url

  def initialize(url)
    @url = url
  end
end
