shared_context :authenticated do |role|
  let(:user) { create :user, role, :day_registered }
  before { sign_in user }
end

shared_context :back_redirect do
  let(:back_url) { 'where_i_came_from' }
  before { request.env['HTTP_REFERER'] = back_url }
end

shared_context :view_object_warden_stub do
  before { view.h.request.env['warden'] ||= WardenStub.new }
end

shared_context :seeds do
  let(:user) { seed :user }
  let(:offtopic_section) { seed :offtopic_section }
  let(:reviews_section) { seed :reviews_section }
  let(:anime_section) { seed :anime_section }
  let(:seeded_offtopic_topic) { seed :topic }
end
