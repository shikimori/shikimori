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
    let(:make_request) { get :edit, id: entry.to_param }

    context 'guest' do
      before { make_request }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      before { make_request }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#edit_field' do
    let(:make_request) { get :edit_field, id: entry.to_param, field: field }

    context 'guest' do
      let(:field) { 'russian' }
      before { make_request }

      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'user' do
      include_context :authenticated, :user

      describe 'russian' do
        let(:field) { 'russian' }
        before { make_request }

        it { expect(response).to have_http_status :success }
      end

      describe 'name' do
        let(:field) { 'name' }
        it { expect{make_request}.to raise_error CanCan::AccessDenied }
      end
    end

    context 'versions moderator' do
      include_context :authenticated, :versions_moderator

      describe 'russian' do
        let(:field) { 'russian' }
        before { make_request }

        it { expect(response).to have_http_status :success }
      end

      describe 'name' do
        let(:field) { 'name' }
        before { make_request }

        it { expect(response).to have_http_status :success }
      end
    end
  end

  describe '#update' do
    let(:make_request) { patch :update,
      { id: entry.id }.merge(entry_name => changes) }
    let(:role) { :user }

    describe 'common user' do
      include_context :authenticated, :user

      context 'common change' do
        before { make_request }
        let(:changes) {{ russian: 'test' }}

        it do
          expect(resource).to_not have_attributes changes
          expect(resource.versions[:russian]).to have(1).item
          expect(resource.versions[:russian].first).to be_pending
          expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
        end
      end

      context 'significant change' do
        let(:changes) {{ name: 'test' }}
        it { expect{make_request}.to raise_error CanCan::AccessDenied }
      end
    end

    describe 'moderator' do
      include_context :authenticated, :versions_moderator
      let(:changes) {{ russian: 'test' }}
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
