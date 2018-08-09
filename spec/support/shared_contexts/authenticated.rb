shared_context :authenticated do |role, register_trait|
  if role
    if role == :admin && !register_trait
      let(:user) { seed :user_admin }
    elsif role == :user && !register_trait
      let(:user) { seed :user }
    else
      let(:user) { create :user, role, register_trait || :day_registered }
    end
  end

  before { sign_in user }
end
