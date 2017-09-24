shared_context :authenticated do |role, register_trait|
  let(:user) { create :user, role, register_trait || :day_registered }
  before { sign_in user }
end
