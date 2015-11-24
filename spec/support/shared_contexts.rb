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
    allow(view.h).to receive(:current_user).and_return user.decorate
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
  let(:offtopic_section) { seed :offtopic_section }
  let(:reviews_section) { seed :reviews_section }
  let(:anime_section) { seed :anime_section }
  let(:contests_section) { seed :contests_section }
  let(:seeded_offtopic_topic) { seed :topic }
end
