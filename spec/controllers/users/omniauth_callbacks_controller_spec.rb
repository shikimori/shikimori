require 'deep_struct'

describe Users::OmniauthCallbacksController, :vcr do
  let(:uid) { 'test' }
  let(:token_number) { '123456789iouhg' }
  let(:provider) { :vkontakte }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = DeepStruct.new(
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

  describe '#sign_up' do
    let(:make_request) { get provider }

    [:facebook, :twitter, :vkontakte].each do |provider|
      describe "##{provider}" do
        it do
          expect(proc do
            expect { make_request }.to change(User, :count).by 1
          end).to change(UserToken, :count).by 1
          expect(response).to redirect_to root_path
        end
      end
    end

    context 'present nickname' do
      let!(:user) { create :user, nickname: 'test' }
      before { make_request }
      it { expect(resource.nickname).to eq 'test2' }
    end
  end

  describe '#sign_in' do
    let!(:user) { create :user }
    let!(:user_token) { create :user_token, user: user, uid: uid, provider: provider }

    let(:make_request) { get provider }

    it do
      expect(proc do
        expect { make_request }.to_not change User, :count
      end).to_not change UserToken, :count
      expect(response).to redirect_to root_path
    end
  end
end
