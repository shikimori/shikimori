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
      before { get :edit, id: entry.to_param }

      describe 'russian' do
        let(:page) { 'russian' }
        it { expect(response).to have_http_status :success }
      end
    end
  end

  describe '#edit_field' do
    context 'guest' do
      let(:page) { nil }
      before { get :edit_field, id: entry.to_param, field: 'russian' }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :edit_field, id: entry.to_param, field: 'russian' }

      describe 'russian' do
        let(:page) { 'russian' }
        it { expect(response).to have_http_status :success }
      end
    end
  end

  describe '#update' do
    let(:make_request) { patch :update,
      { id: entry.id }.merge(entry_name => changes) }
    let(:changes) {{ russian: 'test' }}
    let(:role) { :user }

    describe 'common user' do
      include_context :authenticated, :user
      before { make_request }

      it do
        expect(resource).to_not have_attributes changes
        expect(resource.versions[:russian]).to have(1).item
        expect(resource.versions[:russian].first).to be_pending
        expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
      end
    end

    describe 'moderator' do
      include_context :authenticated, :versions_moderator
      before { make_request }

      it do
        expect(resource).to have_attributes changes
        expect(resource.versions[:russian]).to have(1).item
        expect(resource.versions[:russian].first).to be_accepted
        expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
      end
    end
  end
end
