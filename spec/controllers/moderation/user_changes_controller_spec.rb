describe Moderation::UserChangesController do
  let(:anime) { create :anime }
  let!(:user_change) { create :user_change, :with_user, item_id: anime.id, model: anime.class.name }

  describe '#show' do
    before { get :show, id: user_change.id }
    it { should respond_with :success }
  end

  describe '#tooltip' do
    before { get :tooltip, id: user_change.id }
    it { should respond_with :success }
  end

  describe '#index' do
    context 'guest' do
      before { get :index }
      it { should redirect_to users_sign_in_url }
    end

    context 'user' do
      include_context :authenticated, :user
      before { get :index }
      it { should respond_with :forbidden }
    end

    context 'user changes moderator' do
      include_context :authenticated, :user_changes_moderator
      before { get :index }
      it { should respond_with :success }
    end
  end

  describe '#create' do
    let(:params) {{ model: anime.class.name, column: 'russian', item_id: anime.id, value: 'zxxcv' }}

    context 'guest' do
      before { post :create, user_change: params }
      it { should redirect_to anime_url(anime) }
      it { expect(resource).to be_persisted }
      it { expect(resource).to have_attributes params }
      it { expect(resource.user_id).to eq User::GuestID }
      it { expect(resource.status).to eq UserChangeStatus::Pending }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      before { post :create, user_change: params, is_applied: is_applied }
      let(:is_applied) { }

      context 'with changes' do
        it { should redirect_to anime_url(anime) }
        it { expect(resource).to be_persisted }
        it { expect(resource).to have_attributes params }
        it { expect(resource.user_id).to eq user.id }
        it { expect(resource.status).to eq UserChangeStatus::Pending }
      end

      context 'no changes' do
        let(:anime) { create :anime, russian: 'zxxcv' }
        it { should redirect_to anime_url(anime) }
        it { expect(resource).to be_new_record }
      end
    end
  end

  describe '#take' do
    context 'guest' do
      before { post :take, id: user_change.id }
      it { should redirect_to users_sign_in_url }
    end

    context 'user' do
      include_context :authenticated, :user
      before { post :take, id: user_change.id }
      it { should respond_with :forbidden }
    end

    context 'user changes moderator' do
      include_context :authenticated, :user_changes_moderator
      before { post :take, id: user_change.id, is_applied: is_applied }

      context 'applied' do
        let(:is_applied) { true }
        it { should redirect_to moderation_user_changes_url }
        it { expect(resource.status).to eq UserChangeStatus::Accepted }
        it { expect(anime.reload.russian).to eq user_change.value }
      end

      context 'not applied' do
        let(:is_applied) { }
        it { should redirect_to moderation_user_changes_url }
        it { expect(resource.status).to eq UserChangeStatus::Taken }
        it { expect(anime.reload.russian).to eq user_change.value }
      end
    end
  end

  describe '#deny' do
    context 'guest' do
      before { post :deny, id: user_change.id }
      it { should redirect_to users_sign_in_url }
    end

    context 'user' do
      include_context :authenticated, :user
      before { post :deny, id: user_change.id }
      it { should respond_with :forbidden }
    end

    context 'user changes moderator' do
      include_context :authenticated, :user_changes_moderator
      before { post :deny, id: user_change.id, is_deleted: is_deleted }

      context 'deleted' do
        let(:is_deleted) { true }
        it { should redirect_to moderation_user_changes_url }
        it { expect(resource.status).to eq UserChangeStatus::Deleted }
        it { expect(anime.russian).to eq anime.reload.russian }
      end

      context 'denied' do
        let(:is_deleted) { }
        it { should redirect_to moderation_user_changes_url }
        it { expect(resource.status).to eq UserChangeStatus::Rejected }
        it { expect(anime.russian).to eq anime.reload.russian }
      end
    end
  end
end
