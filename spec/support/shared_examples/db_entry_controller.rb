shared_examples :db_entry_controller do |entry_name|
  let(:entry) { send entry_name }

  describe '#tooltip' do
    before { get :tooltip, params: { id: entry.to_param } }
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

      context 'page 2' do
        let(:make_request) { get :edit, params: { id: entry.to_param, page: 2 }, format: :json }
        it { expect(response).to have_http_status :success }
      end
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

    context 'version_names_moderator' do
      include_context :authenticated, :version_names_moderator

      let(:field) { 'russian' }
      before { make_request }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#update' do
    let(:make_request) do
      patch :update, params: { id: entry.id }.merge(entry_name => changes)
    end
    let(:role) { :user }
    let(:versions) { VersionsQuery.by_item(resource) }

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
      include_context :authenticated, :version_names_moderator
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

  describe '#sync' do
    let(:make_request) { post :sync, params: { id: entry.id } }
    before do
      entry.update mal_id: 123
      allow(MalParsers::FetchEntry).to receive :perform_async
    end

    describe 'common user' do
      include_context :authenticated, :user, :week_registered
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
        expect(MalParsers::FetchEntry).to_not have_received :perform_async
      end
    end

    describe 'moderator' do
      include_context :authenticated, :version_moderator
      before { make_request }

      it do
        expect(MalParsers::FetchEntry)
          .to have_received(:perform_async)
          .with entry.mal_id, entry.class.base_class.name.downcase
        expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
      end
    end
  end

  describe '#merge' do
    let(:make_request) { delete :merge, params: { id: entry.id, target_id: entry_2.id } }
    let(:entry_2) { build_stubbed entry.class.name.downcase.to_sym }

    before { allow(DbEntries::MergeIntoOther).to receive :perform_in }

    describe 'not super moderator' do
      include_context :authenticated, :version_moderator
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
        expect(DbEntries::MergeIntoOther).to_not have_received :perform_in
      end
    end

    describe 'super moderator' do
      include_context :authenticated, :super_moderator
      before { make_request }

      it do
        expect(DbEntries::MergeIntoOther)
          .to have_received(:perform_in)
          .with(
            described_class::DANGEROUS_ACTION_DELAY_INTERVAL,
            entry.class.base_class.name,
            entry.id,
            entry_2.id,
            user.id
          )
        expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
      end
    end
  end

  describe '#destroy' do
    let(:make_request) { delete :destroy, params: { id: entry.id } }

    before { allow(DbEntries::Destroy).to receive :perform_in }

    describe 'not super moderator' do
      include_context :authenticated, :version_moderator
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
        expect(DbEntries::Destroy).to_not have_received :perform_in
      end
    end

    describe 'super moderator' do
      include_context :authenticated, :super_moderator
      before { make_request }

      it do
        expect(DbEntries::Destroy)
          .to have_received(:perform_in)
          .with(
            described_class::DANGEROUS_ACTION_DELAY_INTERVAL,
            entry.class.base_class.name,
            entry.id,
            user.id
          )
        expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
      end
    end
  end
end
