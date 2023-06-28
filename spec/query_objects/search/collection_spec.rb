describe Search::Collection do
  subject do
    described_class.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Collection.all }
    let(:ids_limit) { 2 }

    context 'elastic search' do
      let(:phrase) { 'zxct' }
      let!(:collection_1) { create :collection }
      let!(:collection_2) { create :collection }

      before do
        allow(Elasticsearch::Query::Collection)
          .to receive(:call)
          .with(phrase: phrase, limit: ids_limit)
          .and_return results
      end
      let(:results) { { collection_1.id => 0.123123 } }

      it { is_expected.to eq [collection_1] }
    end

    context 'tags' do
      let!(:collection_1) do
        create :collection,
          tags: %w[anime test],
          cached_votes_up: 99,
          cached_votes_down: 90
      end
      let!(:collection_2) do
        create :collection,
          tags: %w[test],
          cached_votes_up: 10,
          cached_votes_down: 0
      end

      context 'single tag' do
        context do
          let(:phrase) { '#anime' }
          it { is_expected.to eq [collection_1] }
        end

        context do
          let(:phrase) { '#test' }
          it { is_expected.to eq [collection_2, collection_1] }
        end
      end

      context 'multiple tag' do
        let(:phrase) { ['#anime #test', '#anime, #test'].sample }
        it { is_expected.to eq [collection_1] }
      end
    end
  end
end
