describe Search::Collection do
  subject { described_class.call scope:, phrase:, ids_limit: }

  let(:scope) { Collection.all }
  let(:ids_limit) { 2 }

  context 'elastic search' do
    let(:phrase) { 'zxct' }
    let!(:collection_1) { create :collection }
    let!(:collection_2) { create :collection }

    before do
      allow(Elasticsearch::Query::Collection)
        .to receive(:call)
        .with(phrase:, limit: ids_limit)
        .and_return results
    end
    let(:results) { { collection_1.id => 0.123123 } }

    it { is_expected.to eq [collection_1] }
  end

  context 'tags search' do
    let!(:collection_1) do
      create :collection, collection_1_kind,
        tags: %w[аниме test],
        cached_votes_up: 99,
        cached_votes_down: 90
    end
    let!(:collection_2) do
      create :collection, collection_2_kind,
        tags: %w[test],
        cached_votes_up: 10,
        cached_votes_down: 0
    end
    let(:collection_1_kind) { Types::Collection::Kind[:manga] }
    let(:collection_2_kind) { Types::Collection::Kind[:manga] }

    context 'single tag' do
      context do
        let(:phrase) { ['#anime', '#аниме', '#Аниме'].sample }
        it { is_expected.to eq [collection_1] }

        context 'kind tag' do
          let(:collection_2_kind) { Types::Collection::Kind[:anime] }
          it { is_expected.to eq [collection_2, collection_1] }
        end
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
