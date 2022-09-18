describe Clubs::Query do
  include_context :timecop

  let(:query) { described_class.fetch user, locale, is_skip_restrictions }
  let(:locale) { :ru }
  let(:is_skip_restrictions) { false }

  let!(:club_1) { create :club, :with_topics, name: 'club_1' }
  let!(:club_censored) do
    create :club, :with_topics, :censored, name: 'club_censored'
  end
  let!(:club_en) { create :club, :with_topics, locale: :en, name: 'club_en' }
  let!(:club_shadowbanned) do
    create :club, :with_topics, :shadowbanned, name: 'club_shadowbanned'
  end
  let!(:club_private) do
    create :club, :with_topics, :private, name: 'club_private'
  end
  let!(:club_favoured) do
    create :club, :with_topics,
      id: Clubs::Query::FAVOURED_IDS.max,
      name: 'club_favoured'
  end

  describe '.fetch' do
    subject { query }

    it { is_expected.to eq [club_1, club_censored, club_private, club_favoured] }

    context 'is_skip_restrictions' do
      let(:is_skip_restrictions) { true }

      it do
        is_expected.to eq [
          club_1,
          club_censored,
          club_shadowbanned,
          club_private,
          club_favoured
        ]
      end
    end

    context 'user not signed in' do
      let(:user) { nil }
      it { is_expected.to eq [club_1, club_favoured] }
    end

    context 'signed in member of shadowbanned club' do
      before { club_shadowbanned.members << user }
      it do
        is_expected.to eq [
          club_1,
          club_censored,
          club_shadowbanned,
          club_private,
          club_favoured
        ]
      end
    end

    describe '#favourites' do
      subject { query.favourites }
      it { is_expected.to eq [club_favoured] }
    end

    describe '#without_favourites' do
      subject { query.without_favourites }
      it { is_expected.to eq [club_1, club_censored, club_private] }
    end

    describe '#without_censored' do
      subject { query.without_censored }
      it { is_expected.to eq [club_1, club_private, club_favoured] }
    end

    describe '#without_private' do
      subject { query.without_private }
      it { is_expected.to eq [club_1, club_censored, club_favoured] }
    end

    describe '#without_shadowbanned' do
      subject { query.without_shadowbanned }
      it { is_expected.to eq [club_1, club_censored, club_private, club_favoured] }
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
            club_1.id => 765,
            club_en.id => 654
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [club_censored, club_1]
          expect(Elasticsearch::Query::Club).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::Club).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [club_1, club_censored, club_private, club_favoured]
          expect(Elasticsearch::Query::Club).to_not have_received :call
        end
      end
    end
  end
end
