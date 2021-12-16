describe ProfilesController do
  let!(:user) { create :user }

  describe '#show' do
    subject! { get :show, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#friends' do
    context 'without friends' do
      subject! { get :friends, params: { id: user.to_param } }
      it { expect(response).to redirect_to profile_url(user) }
    end

    context 'with friends' do
      let!(:friend_link) { create :friend_link, src: user, dst: create(:user) }
      subject! { get :friends, params: { id: user.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#clubs' do
    context 'without clubs' do
      subject! { get :clubs, params: { id: user.to_param } }
      it { expect(response).to redirect_to profile_url(user) }
    end

    context 'with clubs' do
      let(:club) { create :club, :with_topics }
      let!(:club_role) { create :club_role, user: user, club: club }
      subject! { get :clubs, params: { id: user.to_param } }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#favorites' do
    context 'without favorites' do
      subject! { get :favorites, params: { id: user.to_param } }
      it { expect(response).to redirect_to profile_url(user) }
    end

    context 'with favorites' do
      let!(:favourite) { create :favourite, user: user, linked: create(:anime) }
      subject! { get :favorites, params: { id: user.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#critiques' do
    let!(:critique) { create :critique, :with_topics, user: user }
    subject! { get :critiques, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#reviews' do
    let!(:review) { create :review, user: user, anime: anime }
    let(:anime) { create :anime }
    subject! { get :reviews, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#collections' do
    let!(:collection) { create :collection, :with_topics, user: user }
    subject! { get :collections, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#feed' do
    include_context :authenticated
    let!(:comment) { create :comment, user: user, commentable: user }
    subject! { get :feed, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#topics' do
    let!(:topic) { create :topic, user: user }
    subject! { get :topics, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#comments' do
    let!(:comment) { create :comment, user: user, commentable: user }
    subject! { get :comments, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#versions' do
    let(:anime) { create :anime }
    let!(:version) do
      create :version,
        user: user,
        item: anime,
        item_diff: { name: ['test', 'test2'] },
        state: :accepted
    end
    subject! { get :versions, params: { id: user.to_param } }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
    end
  end

  describe '#moderation' do
    subject! { get :moderation, params: { id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    let(:make_request) { get :edit, params: { id: user.to_param, section: section } }

    context 'when valid access' do
      before { sign_in user }
      subject! { make_request }

      describe 'account' do
        let(:section) { 'account' }
        it { expect(response).to have_http_status :success }
      end

      describe 'profile' do
        let(:section) { 'profile' }
        it { expect(response).to have_http_status :success }
      end

      describe 'password' do
        let(:section) { 'password' }
        it { expect(response).to have_http_status :success }
      end

      describe 'styles' do
        let!(:user) { create :user, :with_assign_style }
        let(:section) { 'styles' }
        it { expect(response).to have_http_status :success }
      end

      describe 'list' do
        let(:section) { 'list' }
        it { expect(response).to have_http_status :success }
      end

      describe 'notifications' do
        let(:section) { 'notifications' }
        it { expect(response).to have_http_status :success }
      end

      describe 'misc' do
        let(:section) { 'misc' }
        it { expect(response).to have_http_status :success }
      end
    end

    context 'when invalid access' do
      let(:section) { 'account' }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#update' do
    let(:make_request) do
      patch :update, params: { id: user.to_param, section: 'account', user: update_params }
    end

    context 'when valid access' do
      before { sign_in user }

      context 'when success' do
        subject! { make_request }

        context 'common change' do
          let(:update_params) { { nickname: 'morr' } }

          it do
            expect(resource.nickname).to eq 'morr'
            expect(resource.errors).to be_empty
            expect(response).to redirect_to edit_profile_url(resource, section: 'account')
          end
        end

        context 'association change' do
          let(:user_2) { create :user }
          let(:update_params) { { ignored_user_ids: [user_2.id] } }

          it do
            expect(resource.ignores?(user_2)).to be true
            expect(resource.errors).to be_empty
          end
        end

        context 'password change' do
          context 'when current password is set' do
            let(:user) { create :user, password: '1234' }
            let(:update_params) { { current_password: '1234', password: 'yhn' } }

            it do
              expect(resource.valid_password?('yhn')).to be true
              expect(resource.errors).to be_empty
            end
          end

          context 'when current password is not set' do
            let(:user) { create :user, :without_password }
            let(:update_params) { { password: 'yhn' } }

            it do
              expect(resource.valid_password?('yhn')).to be true
              expect(resource.errors).to be_empty
            end
          end
        end
      end

      context 'when validation errors' do
        let!(:user_2) { create :user }
        let(:update_params) { { nickname: user_2.nickname } }
        subject! { make_request }

        it do
          expect(resource.errors).to_not be_empty
          expect(response).to have_http_status :success
        end
      end
    end

    context 'when invalid access' do
      let(:update_params) { { nickname: '123' } }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
