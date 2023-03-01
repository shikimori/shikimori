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

    context '#by_desynced' do
      subject { query.by_desynced 'zzz', user }
      before do
        allow(Animes::Filters::ByDesynced)
          .to receive(:call)
          .and_return characters_scope
      end
      let(:characters_scope) { Character.where id: character_1.id }

      context 'staff user' do
        let(:user) { seed :user_admin }
        it do
          is_expected.to eq [character_1]
          expect(Animes::Filters::ByDesynced)
            .to have_received(:call)
            .with(any_args, 'zzz')
        end
      end

      context 'not staff user' do
        let(:user) { [seed(:user), nil].sample }
        it do
          is_expected.to eq [character_1, character_2, character_3]
          expect(Animes::Filters::ByDesynced).to_not have_received :call
        end
      end
    end
  end
end
