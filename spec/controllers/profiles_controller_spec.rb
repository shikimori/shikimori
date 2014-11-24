describe ProfilesController do
  let!(:user) { create :user }

  describe '#show' do
    before { get :show, id: user.to_param }
    it { should respond_with :success }
  end

  describe '#friends' do
    context 'without friends' do
      before { get :friends, id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with friends' do
      let!(:friend_link) { create :friend_link, src: user, dst: create(:user) }
      before { get :friends, id: user.to_param }
      it { should respond_with :success }
    end
  end

  describe '#clubs' do
    context 'without clubs' do
      before { get :clubs, id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with clubs' do
      let!(:club_role) { create :group_role, user: user }
      before { get :clubs, id: user.to_param }
      it { should respond_with :success }
    end
  end

  describe '#favourites' do
    context 'without favourites' do
      before { get :favourites, id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with favourites' do
      let!(:favourite) { create :favourite, user: user, linked: create(:anime) }
      before { get :favourites, id: user.to_param }
      it { should respond_with :success }
    end
  end

  describe '#comments' do
    let!(:comment_role) { create :comment, user: user, commentable: user }
    before { get :comments, id: user.to_param }
    it { should respond_with :success }
  end

  #describe '#stats' do
    #before { get :stats, id: user.to_param }
    #it { should respond_with :success }
  #end

  describe '#edit' do
    let(:make_request) { get :edit, id: user.to_param, page: page }

    context 'when valid access' do
      before { sign_in user }
      before { make_request }

      describe 'account' do
        let(:page) { 'account' }
        it { should respond_with :success }
      end

      describe 'profile' do
        let(:page) { 'profile' }
        it { should respond_with :success }
      end

      describe 'password' do
        let(:page) { 'password' }
        it { should respond_with :success }
      end

      describe 'styles' do
        let(:page) { 'styles' }
        it { should respond_with :success }
      end

      describe 'list' do
        let(:page) { 'list' }
        it { should respond_with :success }
      end

      describe 'notifications' do
        let(:page) { 'notifications' }
        it { should respond_with :success }
      end

      describe 'misc' do
        let(:page) { 'misc' }
        it { should respond_with :success }
      end
    end

    context 'when invalid access' do
      let(:page) { 'account' }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#update' do
    let(:make_request) { patch :update, id: user.to_param, page: 'account', user: update_params }

    context 'when valid access' do
      before { sign_in user }

      context 'when success' do
        before { make_request }

        context 'common change' do
          let(:update_params) {{ nickname: 'morr' }}

          it { should redirect_to edit_profile_url(resource, page: 'account') }
          it { expect(resource.nickname).to eq 'morr' }
          it { expect(resource.errors).to be_empty }
        end

        context 'association change' do
          let(:user_2) { create :user }
          let(:update_params) {{ ignored_user_ids: [user_2.id] }}

          it { expect(resource.ignores?(user_2)).to be true }
          it { expect(resource.errors).to be_empty }
        end

        context 'password change' do
          context 'when current password is set' do
            let(:user) { create :user, password: '1234' }
            let(:update_params) {{ current_password: '1234', password: 'yhn' }}

            it { expect(resource.valid_password?('yhn')).to be true }
            it { expect(resource.errors).to be_empty }
          end

          context 'when current password is not set' do
            let(:user) { create :user, :without_password }
            let(:update_params) {{ password: 'yhn' }}

            it { expect(resource.valid_password?('yhn')).to be true }
            it { expect(resource.errors).to be_empty }
          end
        end
      end

      context 'when validation errors' do
        let!(:user_2) { create :user }
        let(:update_params) {{ nickname: user_2.nickname }}
        before { make_request }

        it { should respond_with :success }
        it { expect(resource.errors).to_not be_empty }
      end
    end

    context 'when invalid access' do
      let(:update_params) {{ nickname: '123' }}
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end
end
