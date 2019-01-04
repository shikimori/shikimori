shared_examples :db_entry_controller do |entry_name|
  let(:entry) { send entry_name }

  describe '#tooltip' do
    before { get :tooltip, params: { id: entry.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#versions' do
    before do
      get :versions, params: { id: entry.to_param, page: 2 }, format: :json
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    let(:make_request) { get :edit, params: { id: entry.to_param } }

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
    let(:make_request) do
      get :edit_field, params: { id: entry.to_param, field: field }
    end

    context 'guest' do
      let(:field) { 'russian' }
      before { make_request }

      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'user' do
      include_context :authenticated, :user, :week_registered

      describe 'russian' do
        let(:field) { 'russian' }
        before { make_request }

        it { expect(response).to have_http_status :success }
      end

      describe 'name' do
        let(:field) { 'name' }
        it { expect { make_request }.to raise_error CanCan::AccessDenied }
      end
    end

    context 'versions moderator' do
      include_context :authenticated, :version_moderator

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
    let(:make_request) do
      patch :update, params: { id: entry.id }.merge(entry_name => changes)
    end
    let(:role) { :user }
    let(:versions) { VersionsQuery.fetch(resource) }

    describe 'common user' do
      include_context :authenticated, :user, :week_registered

      context 'common change' do
        before { make_request }
        let(:changes) { { russian: 'test' } }

        it do
          expect(resource).to_not have_attributes changes
          expect(versions.by_field(:russian)).to have(1).item
          expect(versions.by_field(:russian).first).to be_pending
          expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
        end
      end

      context 'significant change' do
        let(:changes) { { name: 'test' } }
        it { expect { make_request }.to raise_error CanCan::AccessDenied }
      end
    end

    describe 'moderator' do
      include_context :authenticated, :version_moderator
      let(:changes) { { russian: 'test' } }
      before { make_request }

      it do
        expect(resource).to have_attributes changes
        expect(versions.by_field(:russian)).to have(1).item
        expect(versions.by_field(:russian).first).to be_auto_accepted
        expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
      end
    end
  end
end
