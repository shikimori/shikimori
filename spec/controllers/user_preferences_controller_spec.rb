require 'spec_helper'

describe UserPreferencesController do
  let(:user) { create :user, password: '123' }
  before { sign_in user }

  describe :update do
    context 'wrong user' do
      let(:user2) { create :user }
      before { patch :update, id: user2.to_param }
      it { should respond_with :forbidden }
    end

    context 'preference change' do
      before { patch :update, id: user.to_param, page: :profile, user_preferences: { body_background: 'test2' } }
      specify { assigns(:user).preferences.body_background.should eq 'test2' }
      it { should redirect_to user_settings_url(user, page: :profile) }
    end

    context 'about change' do
      before { patch :update, id: user.to_param, page: :profile, user_preferences: { body_background: 'test2' }, user: { about: 'zxc' } }
      specify { assigns(:user).about.should eq 'zxc' }
    end
  end
end
