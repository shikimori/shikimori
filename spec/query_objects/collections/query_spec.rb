describe Collections::Query do
  let(:query) { Collections::Query.fetch(:ru) }

  include_context :timecop

  let!(:collection_1) { create :collection, :published, id: 1 }
  let!(:collection_2) { create :collection, :published, id: 2 }
  let!(:collection_3) { create :collection, :published, id: 3 }
  let!(:collection_4) { create :collection, :unpublished, id: 4 }
  let!(:collection_en_1) { create :collection, :published, id: 5 }
  let!(:collection_en_2) { create :collection, :unpublished, id: 6 }

  describe '.fetch' do
    subject { query }
    it { is_expected.to eq [collection_3, collection_2, collection_1] }

    describe '#search' do
      subject { query.search phrase, 'ru' }

      context 'present search phrase' do
        before do
          allow(Elasticsearch::Query::Collection).to receive(:call).with(
            phrase: phrase,
            locale: 'ru',
            limit: Collections::Query::SEARCH_LIMIT
          ).and_return(
            collection_3.id => 987,
            collection_2.id => 654,
            collection_en_1.id => 321
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [collection_3, collection_2]
          expect(Elasticsearch::Query::Collection).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::Collection).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [collection_3, collection_2, collection_1]
          expect(Elasticsearch::Query::Collection).to_not have_received :call
        end
      end
    end
  end
end
