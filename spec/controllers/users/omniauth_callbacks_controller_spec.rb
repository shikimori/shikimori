require 'deep_struct'

describe Users::OmniauthCallbacksController do
  [:facebook, :twitter, :vkontakte].each do |provider|
    describe "##{provider}" do
      let(:uid) { 'test' }
      let(:token_number) { '123456789iouhg' }

      before do
        request.env['devise.mapping'] = Devise.mappings[:user]
        @controller.env['omniauth.auth'] = DeepStruct.new(
          provider: provider.to_s,
          uid: uid,
          credentials: { token: token_number, refresh_token: token_number },
          info: {
            email: 'test@test.com',
            name: 'test'
          },
          extra: {
            raw_info: {}
          }
        )
      end

      context 'no token' do
        let(:make_request) { get provider }

        it { expect{make_request}.to change(User, :count).by 1 }
        it { expect{make_request}.to change(UserToken, :count).by 1 }

        describe 'response' do
          before { make_request }
          it { expect(response).to redirect_to :root }
        end

        context 'present nickname' do
          let!(:user) { create :user, nickname: 'test' }
          before { make_request }
          it { expect(resource.nickname).to eq 'test2' }
        end
      end

      context 'with token' do
        let!(:user) { create :user }
        let!(:user_token) { create :user_token, user: user, uid: uid, provider: provider }

        let(:make_request) { get provider }

        it { expect{make_request}.to_not change User, :count }
        it { expect{make_request}.to_not change UserToken, :count }

        describe 'response' do
          before { make_request }
          it { expect(response).to redirect_to :root }
        end
      end
    end
  end
end
