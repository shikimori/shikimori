shared_context :view_context_stub do
  let(:view_context_params) { {} }
  before do
    # Draper::ViewContext.test_strategy :full
    # Draper::ViewContext.build!
    # Draper::ViewContext.current.controller.request =
      # ActionController::TestRequest.create(ShikimoriController)

    view_context = view.h

    view_context.request.env['warden'] ||= WardenStub.new
    allow(view_context)
      .to receive(:params)
      .and_return ActionController::Parameters.new(view_context_params)
    allow(view_context)
      .to receive(:current_user)
      .and_return(user ? user.decorate : nil)
    allow(view_context.controller)
      .to receive(:default_url_options)
      .and_return ApplicationController.default_url_options

    def view_context.domain_migration_note
      false
    end

    allow(view_context)
      .to receive(:page)
      .and_return(view_context.params[:page] || 1)

    # allow(view_context).to receive(:censored_forbidden?).and_return true
    def view_context.censored_forbidden?
      true
    end
  end

  after do
    if view.h.respond_to? :request
      view.h.request.env['warden'] = nil
    end

    view.h.instance_variable_set '@current_user', nil

    if view.h.respond_to? :controller
      view.h.controller.instance_variable_set '@current_user', nil
      view.h.controller.instance_variable_set '@decorated_current_user', nil
    end
    # в каких-то случаях params почему-то не очищается
    # словил падение view object спеки от того, что в params лежали данные от
    # предыдущего контроллера
    if view.h.respond_to? :params
      view.h.params.delete_if { true }
    end
  end
end
