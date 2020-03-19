describe IgnoresController do
  include_context :authenticated, :user

  describe '#create' do
    let(:user_1) { create :user }
    let(:user_2) { create :user }
    let(:user_3) { create :user }
    let!(:preset_ignore) { create :ignore, user: user, target: user_3 }

    before { post :create, params: { user_ids: user_ids } }
    let(:user_ids) { [user_1.id, user_1.id, user_2.id, user_3.id] }

    it do
      expect(user.ignores? user_1).to eq true
      expect(user.ignores? user_2).to eq true
      expect(user.ignores? user_3).to eq true
      expect(user.ignores).to have(3).items

      expect(response)
        .to redirect_to edit_profile_url(user, section: 'ignored_topics')
    end
  end
end
