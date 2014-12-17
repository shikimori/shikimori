module Responders::JsonResponder
  protected

  # simply render the resource even on POST instead of redirecting for ajax
  def api_behavior
    if post?
      display resource, :status => :created
    # render resource instead of 204 no content
    elsif put? || patch?
      display resource, :status => :ok
    else
      super
    end
  end
end
