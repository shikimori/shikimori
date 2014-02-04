require 'spec_helper'
require 'deep_struct'

describe Users::OmniauthCallbacksController do
  [:facebook, :twitter, :vkontakte].each do |provider|
    context provider do
      let(:uid) { 'test' }
      let(:token_number) { '123456789iouhg' }

      before do
        request.env["devise.mapping"] = Devise.mappings[:user]
        @controller.env['omniauth.auth'] = DeepStruct.new(
          provider: provider.to_s,
          uid: uid,
          credentials: {token: token_number, refresh_token: token_number},
          info: {
            email: 'test@test.com',
            name: 'test'
          },
          extra: {
            raw_info: {}
          }
        )
      end

      context :no_token do
        subject { get provider }

        it { expect{subject}.to change(User, :count).by 1 }
        it { expect{subject}.to change(UserToken, :count).by 1 }
        it { should redirect_to :root }
      end

      context :with_token do
        let(:user) { create :user }
        before { create :user }
        before { create :user_token, user: user, uid: uid, provider: provider }

        subject { get provider }

        it { expect{subject}.to_not change User, :count }
        it { expect{subject}.to_not change UserToken, :count }
        it { should redirect_to :root }
      end
    end
  end
end
