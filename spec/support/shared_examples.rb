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
      include_context :authenticated, :user

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
    let(:make_request) do
      patch :update, params: { id: entry.id }.merge(entry_name => changes)
    end
    let(:role) { :user }

    describe 'common user' do
      include_context :authenticated, :user

      context 'common change' do
        before { make_request }
        let(:changes) { { russian: 'test' } }

        it do
          expect(resource).to_not have_attributes changes
          expect(resource.versions[:russian]).to have(1).item
          expect(resource.versions[:russian].first).to be_pending
          expect(response).to redirect_to send("edit_#{entry_name}_url", entry)
        end
      end

      context 'significant change' do
        let(:changes) { { name: 'test' } }
        it { expect { make_request }.to raise_error CanCan::AccessDenied }
      end
    end

    describe 'moderator' do
      include_context :authenticated, :versions_moderator
      let(:changes) { { russian: 'test' } }
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

shared_examples :topics_concern do |db_entry|
  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'instance methods' do
      let(:model) { build_stubbed db_entry }

      describe '#generate_topics' do
        let(:topics) { model.topics }
        before { model.generate_topics :en }

        it do
          expect(topics).to have(1).item
          expect(topics.first.locale).to eq 'en'
        end
      end

      describe '#topic' do
        let(:topic) { model.topic locale }
        before { model.generate_topics :ru }

        context 'with topic for locale' do
          let(:locale) { :ru }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale
          end
        end

        context 'without topic for locale' do
          let(:locale) { :en }
          it { expect(topic).to be_nil }
        end
      end

      describe '#maybe_topic' do
        let(:topic) { model.maybe_topic locale }
        before { model.generate_topics :ru }

        context 'with topic for locale' do
          let(:locale) { :ru }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale
          end
        end

        context 'without topic for locale' do
          let(:locale) { :en }
          it do
            expect(topic).to be_present
            expect(topic).to be_instance_of NoTopic
            expect(topic.linked).to eq model
          end
        end
      end

      describe '#topic_user' do
        it { expect(model.topic_user).to eq BotsService.get_poster }
      end
    end
  end
end

shared_examples :collections_concern do |db_entry|
  describe 'collections concern' do
    describe 'associations' do
      it { is_expected.to have_many(:collection_links).dependent :destroy }
      it { is_expected.to have_many :collections }
    end
  end
end

shared_examples :elasticsearch_concern do |type|
  describe 'elasticsearch concern' do
    let(:client) { Elasticsearch::Client.instance }
    let(:url) { "#{Elasticsearch::Config::INDEX}/#{type}/#{entry.id}" }
    let(:data_klass) { "Elasticsearch::Data::#{entry.class.name}".constantize }
    let(:data) { data_klass.call entry }

    before do
      allow(Elasticsearch::Create).to receive :perform_async
      allow(Elasticsearch::Update).to receive :perform_async
      allow(Elasticsearch::Destroy).to receive :perform_async
    end

    describe '#post_elastic' do
      let!(:entry) { create type, :with_elasticserach }

      it do
        expect(Elasticsearch::Create).to have_received(:perform_async)
          .with(entry.id, entry.class.name)
        expect(Elasticsearch::Update).to_not have_received :perform_async
        expect(Elasticsearch::Destroy).to_not have_received :perform_async
      end
    end

    describe '#put_elastic' do
      let!(:entry) { create type, :with_elasticserach }

      before { entry.update! field => Time.zone.today.to_s }

      context 'not elastic field' do
        let(:field) { :updated_at }

        it do
          expect(Elasticsearch::Create).to have_received(:perform_async)
            .with(entry.id, entry.class.name)
          expect(Elasticsearch::Update).to_not have_received :perform_async
          expect(Elasticsearch::Destroy).to_not have_received :perform_async
        end
      end

      context 'elastic field' do
        let(:field) { data_klass::TRACK_CHANGES_FIELDS.first }

        it do
          expect(Elasticsearch::Create).to have_received(:perform_async)
            .with(entry.id, entry.class.name)
          expect(Elasticsearch::Update).to have_received(:perform_async)
            .with(entry.id, entry.class.name)
          expect(Elasticsearch::Destroy).to_not have_received :perform_async
        end
      end
    end

    describe '#delete_elastic' do
      let!(:entry) { create type, :with_elasticserach }

      before { entry.destroy! }

      it do
        expect(Elasticsearch::Create).to have_received(:perform_async)
          .with(entry.id, entry.class.name)
        expect(Elasticsearch::Update).to_not have_received :perform_async
        expect(Elasticsearch::Destroy).to have_received(:perform_async)
          .with(entry.id, entry.class.name)
      end
    end
  end
end

shared_examples :touch_related_in_db_entry do |db_entry|
  describe '#touch_related' do
    let(:model) { create db_entry }
    before do
      allow(DbEntries::TouchRelated).to receive :perform_async
    end
    subject! do
      db_entry.to_s.capitalize.constantize
        .find(model.id)
        .update(field => 'test 123456')
    end

    context 'russian' do
      let(:field) { :russian }
      it { expect(DbEntries::TouchRelated).to have_received(:perform_async).with model.id }
    end

    context 'name' do
      let(:field) { :name }
      it { expect(DbEntries::TouchRelated).to have_received(:perform_async).with model.id }
    end

    context 'other fields' do
      let(:field) { :updated_at }
      it { expect(DbEntries::TouchRelated).to_not have_received :perform_async }
    end
  end
end
