shared_context :authenticated do |role|
  let(:user) { create :user, role }
  before { sign_in user }
end
