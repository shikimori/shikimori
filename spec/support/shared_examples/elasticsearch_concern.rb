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
