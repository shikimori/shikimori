shared_context :view_object_warden_stub do
  before do
    # Draper::ViewContext.test_strategy :full
    # Draper::ViewContext.build!
    # Draper::ViewContext.current.controller.request =
      # ActionController::TestRequest.create(ShikimoriController)

    view_context = view.h

    view_context.request.env['warden'] ||= WardenStub.new
    allow(view_context).to receive(:current_user).and_return(
      user ? user.decorate : nil
    )
    def view_context.censored_forbidden?; true; end
    # allow(view_context).to receive(:censored_forbidden?).and_return true
    allow(view_context.controller).to receive(:default_url_options)
      .and_return ApplicationController.default_url_options
  end

  after do
    view.h.request.env['warden'] = nil
    view.h.instance_variable_set '@current_user', nil
    view.h.controller.instance_variable_set '@current_user', nil
    view.h.controller.instance_variable_set '@decorated_current_user', nil
    # в каких-то случаях params почему-то не очищается
    # словил падение view object спеки от того, что в params лежали данные от
    # предыдущего контроллера
    view.h.params.delete_if { true }
  end
end
