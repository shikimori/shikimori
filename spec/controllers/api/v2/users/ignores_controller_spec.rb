describe Api::V2::Users::IgnoresController, :show_in_doc do
  include_context :authenticated, :user

  let(:target_user) { create :user }

  describe '#create' do
    before { post :create, params: { user_id: target_user.id } }

    it do
      expect(user.ignores).to have(1).item
      expect(user.ignores.first).to have_attributes target_id: target_user.id
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let!(:user_ignore) { create :ignore, user: user, target: target_user }
    before { delete :destroy, params: { user_id: target_user.id } }

    it do
      expect { user_ignore.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to have_http_status :success
    end
  end
end
