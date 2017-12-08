module ControllerResource
  def resource
    assigns(:resource) || (
      controller.send(:resource) if controller.respond_to?(:resource, true)
    )
  end

  def collection
    assigns(:collection) || (
      controller.send(:collection) if controller.respond_to?(:collection, true)
    )
  end
end
