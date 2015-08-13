shared_examples :db_entry_controller do |entry_name|
  let(:entry) { send entry_name }

  describe '#tooltip' do
    before { get :tooltip, id: entry.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#versions' do
    before { get :versions, id: entry.to_param, page: 2, format: :json }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    context 'guest' do
      let(:page) { nil }
      before { get :edit, id: entry.to_param }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :edit, id: entry.to_param, page: page }

      describe 'russian' do
        let(:page) { 'russian' }
        it { expect(response).to have_http_status :success }
      end
    end
  end
  
  describe '#update' do
    include_context :back_redirect
    let(:make_request) { patch :update,
      { id: entry.id, apply: apply, take: take }.merge(entry_name => changes) }
    let(:changes) {{ russian: 'test' }}
    let(:role) { :user }

    describe 'save' do
      include_context :authenticated, :user
      let(:apply) { }
      let(:take) { }
      before { make_request }

      it do
        expect(resource).to_not have_attributes changes
        expect(resource.versions[:russian]).to have(1).item
        expect(resource.versions[:russian].first).to be_pending
        expect(response).to redirect_to back_url
      end
    end

    describe 'apply' do
      let(:apply) { 'Apply' }
      let(:take) { }

      context 'common user' do
        include_context :authenticated, :user
        before { make_request }

        it do
          expect(resource).to_not have_attributes changes
          expect(resource.versions[:russian]).to have(1).item
          expect(resource.versions[:russian].first).to be_pending
          expect(response).to redirect_to back_url
        end
      end

      context 'moderator' do
        include_context :authenticated, :user_changes_moderator
        before { make_request }

        it do
          expect(resource).to have_attributes changes
          expect(resource.versions[:russian]).to have(1).item
          expect(resource.versions[:russian].first).to be_accepted
          expect(response).to redirect_to back_url
        end
      end
    end

    describe 'take' do
      let(:apply) { }
      let(:take) { 'Take' }

      include_context :authenticated, :user_changes_moderator
      before { make_request }

      it do
        expect(resource).to have_attributes changes
        expect(resource.versions[:russian]).to have(1).item
        expect(resource.versions[:russian].first).to be_taken
        expect(response).to redirect_to back_url
      end
    end
  end
end
