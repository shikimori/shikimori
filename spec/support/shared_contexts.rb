shared_context :authenticated do |role|
  let(:user) { create :user, role, :day_registered }
  before { sign_in user }
end
