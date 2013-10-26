require 'spec_helper'

describe AdminLogInController do
  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let (:user) { FactoryGirl.create :user, nickname: 'zxcxcbvvc' }

  describe 'GET restore' do
    before :each do
      sign_in FactoryGirl.create(:user)
    end

    context 'no saved admin in session' do
      it 'not found' do
        get :restore
        response.should be_not_found
      end
    end

    context 'saved admin in session' do
      before :each do
        session[AdminLogInController.admin_id_to_restore_key] = user.id
      end

      it 'deletes admin id from session' do
        get :restore
        session[AdminLogInController.admin_id_to_restore_key].should be_nil
      end

      it 'restores user' do
        get :restore
        assigns(:user).id.should eq user.id
      end

      it 'redirects to root' do
        get :restore
        response.should redirect_to(root_url)
      end
    end
  end

  describe 'GET log_in' do
    context 'admin' do
      before :each do
        @admin = FactoryGirl.create :user, id: 1
        sign_in @admin
      end

      it 'changes current_user' do
        get :log_in, nickname: user.nickname
        assigns(:user).id.should eq user.id
      end

      it 'saves admin id in session' do
        get :log_in, nickname: user.nickname
        session[AdminLogInController.admin_id_to_restore_key].should eq @admin.id
      end

      it 'redirects to root' do
        get :log_in, nickname: user.nickname
        response.should redirect_to(root_url)
      end

      it 'shows 503 for unknown user' do
        get :log_in, nickname: 'zzzzzzzzzzzzzzzzz'
        response.should be_unprocessible_entiy
      end
    end

    context :user do
      before :each do
        sign_in FactoryGirl.create(:user)
      end

      it 'not found' do
        get :log_in, nickname: user.nickname
        response.should be_not_found
      end

      it 'session is not set' do
        get :log_in, nickname: user.nickname
        session[AdminLogInController.admin_id_to_restore_key].should be_nil
      end
    end
  end
end
