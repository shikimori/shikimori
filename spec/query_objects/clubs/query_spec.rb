describe Clubs::Query do
  let(:query) { Clubs::Query.fetch(:ru) }

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
      before do
        allow(Elasticsearch::Query::Club).to receive(:call).with(
          phrase: 'test',
          locale: 'ru',
          limit: Clubs::Query::SEARCH_LIMIT
        ).and_return(
          [
            { '_id' => club_3.id },
            { '_id' => club_2.id },
            { '_id' => club_en.id }
          ]
        )
      end
      subject { query.search 'test', 'ru' }
      it { is_expected.to eq [club_3, club_2] }
    end
  end
end
