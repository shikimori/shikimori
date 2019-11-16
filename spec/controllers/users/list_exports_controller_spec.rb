describe Users::ListExportsController do
  include_context :authenticated, :user

  describe '#show' do
    before { get :show, params: { profile_id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#export' do
    %w[animes mangas].each do |type|
      describe type do
        let!(:user_rate) { create :user_rate, user: user, target: target }
        let(:target) { create type.singularize }

        %w[xml json].each do |format|
          describe format do
            subject! do
              get type,
                params: { profile_id: user.to_param },
                format: format
            end

            it do
              expect(collection).to eq [user_rate]
              expect(response).to have_http_status :success
              expect(response.content_type).to eq "application/#{format}; charset=utf-8"
            end
          end
        end
      end
    end

    context 'no access' do
      let(:user) do
        create :user,
          preferences: create(:user_preferences, list_privacy: :owner)
      end
      before { sign_out user }
      let(:make_request) do
        get :animes,
          params: { profile_id: user.to_param },
          format: :json
      end
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
