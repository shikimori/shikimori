shared_context :authenticated do |role|
  let(:user) { create :user, role, :day_registered }
  before { sign_in user }
end

shared_context :back_redirect do
  let(:back_url) { 'where_i_came_from' }
  before { request.env['HTTP_REFERER'] = back_url }
end

shared_context :view_object_warden_stub do
  before do
    view.h.request.env['warden'] ||= WardenStub.new
    allow(view.h).to receive(:current_user).and_return(
      user ? user.decorate : nil
    )
  end

  after do
    view.h.request.env['warden'] = nil
    view.h.instance_variable_set '@current_user', nil
    view.h.controller.instance_variable_set '@current_user', nil
    view.h.controller.instance_variable_set '@decorated_current_user', nil
  end
end

shared_context :seeds do
  let(:user) { seed :user }

  let(:offtopic_forum) { seed :offtopic_forum }
  let(:reviews_forum) { seed :reviews_forum }
  let(:animanga_forum) { seed :animanga_forum }
  let(:contests_forum) { seed :contests_forum }
  let(:clubs_forum) { seed :clubs_forum }
  let(:cosplay_forum) { seed :cosplay_forum }

  let(:seeded_offtopic_topic) { seed :topic }
end
