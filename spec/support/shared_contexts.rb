shared_context :authenticated do |role|
  let(:user) { create :user, role, :day_registered }
  before { sign_in user }
end

shared_context :back_redirect do
  let(:back_url) { 'where_i_came_from' }
  before { request.env['HTTP_REFERER'] = back_url }
end
