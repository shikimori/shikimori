describe Clubs::Query do
  include_context :timecop

  let(:query) { described_class.fetch is_user_signed_in, locale }
  let(:is_user_signed_in) { true }
  let(:locale) { :ru }

  let!(:club_1) { create :club, :with_topics, id: 1 }
  let!(:club_2) { create :club, :with_topics, id: 2 }
  let!(:club_censored) { create :club, :with_topics, id: 3, is_censored: true }
  let!(:club_en) { create :club, :with_topics, id: 4, locale: :en }
  let!(:club_favoured) { create :club, :with_topics, id: Clubs::Query::FAVOURED_IDS.max }

  describe '.fetch' do
    subject { query }

    it { is_expected.to eq [club_1, club_2, club_censored, club_favoured] }

    context 'user not signed in' do
      let(:is_user_signed_in) { false }
      it { is_expected.to eq [club_1, club_2, club_favoured] }
    end

    describe '#favourites' do
      subject { query.favourites }
      it { is_expected.to eq [club_favoured] }
    end

    describe '#without_favourites' do
      subject { query.without_favourites }
      it { is_expected.to eq [club_1, club_2, club_censored] }
    end

    describe '#without_censored' do
      subject { query.without_censored }
      it { is_expected.to eq [club_1, club_2, club_favoured] }
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
            club_censored.id => 987,
            club_2.id => 765,
            club_en.id => 654
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [club_censored, club_2]
          expect(Elasticsearch::Query::Club).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::Club).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [club_1, club_2, club_censored, club_favoured]
          expect(Elasticsearch::Query::Club).to_not have_received :call
        end
      end
    end
  end
end
