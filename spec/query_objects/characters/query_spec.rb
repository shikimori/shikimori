describe Characters::Query do
  let(:query) { described_class.fetch }

  include_context :timecop

  let!(:character_1) { create :character, id: 1 }
  let!(:character_2) { create :character, id: 2 }
  let!(:character_3) { create :character, id: 3 }

  describe '.fetch' do
    subject { query }
    it { is_expected.to eq [character_1, character_2, character_3] }

    describe '#search' do
      subject { query.search phrase }

      context 'present search phrase' do
        before do
          allow(Elasticsearch::Query::Character).to receive(:call).with(
            phrase: phrase,
            limit: Characters::Query::SEARCH_LIMIT
          ).and_return(
            character_3.id => 987,
            character_2.id => 765
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [character_3, character_2]
          expect(Elasticsearch::Query::Character).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::Character).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [character_1, character_2, character_3]
          expect(Elasticsearch::Query::Character).to_not have_received :call
        end
      end
    end
  end
end
