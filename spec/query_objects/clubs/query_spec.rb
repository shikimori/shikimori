describe Clubs::Query do
  let(:query) { described_class.fetch(:ru) }

  include_context :timecop

  let(:user) { create :user }
  let!(:club_1) { create :club, :with_topics, id: 1 }
  let!(:club_2) { create :club, :with_topics, id: 2 }
  let!(:club_3) { create :club, :with_topics, id: 3 }
  let!(:club_en) { create :club, :with_topics, id: 4, locale: :en }
  let!(:club_favoured) { create :club, :with_topics, id: Clubs::Query::FAVOURED_IDS.max }

  describe '.fetch' do
    subject { query }
    it { is_expected.to eq [club_1, club_2, club_3, club_favoured] }

    describe '#favourites' do
      subject { query.favourites }
      it { is_expected.to eq [club_favoured] }
    end

    describe '#without_favourites' do
      subject { query.without_favourites }
      it { is_expected.to eq [club_1, club_2, club_3] }
    end

    describe '#search' do
      subject { query.search phrase, 'ru' }

      context 'present search phrase' do
        before do
          allow(Elasticsearch::Query::Club).to receive(:call).with(
            phrase: phrase,
            locale: 'ru',
            limit: Clubs::Query::SEARCH_LIMIT
          ).and_return(
            club_3.id => 987,
            club_2.id => 765,
            club_en.id => 654
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [club_3, club_2]
          expect(Elasticsearch::Query::Club).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::Club).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [club_1, club_2, club_3, club_favoured]
          expect(Elasticsearch::Query::Club).to_not have_received :call
        end
      end
    end
  end
end
