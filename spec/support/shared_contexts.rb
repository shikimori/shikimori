shared_context :authenticated do
  let(:user) { create :user }
  before { sign_in user }
end
