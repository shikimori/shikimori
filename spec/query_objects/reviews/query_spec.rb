describe Reviews::Query do
  before do
    Review.wo_antispam do
      @reviews = [
        create(:review, anime: db_entry, user: user_1, opinion: :positive),
        create(:review, anime: db_entry, user: user_2, opinion: :positive, created_at: Reviews::Query::NEW_REVIEW_BUBBLE_INTERVAL.ago),
        create(:review, anime: db_entry, user: user_3, opinion: :negative),
        create(:review, anime: anime, user: user_1, opinion: :neutral)
      ]
    end
  end

  let(:db_entry) { create :anime }
  let(:anime) { create :anime }

  subject(:query) { described_class.fetch db_entry }
  let(:all_non_paginated_revies) { [@reviews[2], @reviews[1], @reviews[0]] }

  describe '.fetch' do
    it { is_expected.to eq all_non_paginated_revies }
  end

  describe '#by_opinion' do
    subject { query.by_opinion opinion }

    context 'positive' do
      let(:opinion) { :positive }
      it { is_expected.to eq [@reviews[1], @reviews[0]] }
    end

    context 'neutral' do
      let(:opinion) { :neutral }
      it { is_expected.to eq [] }
    end

    context 'negative' do
      let(:opinion) { :negative }
      it { is_expected.to eq [@reviews[2]] }
    end

    context 'no opinion' do
      let(:opinion) { [nil, ''].sample }
      it { is_expected.to eq all_non_paginated_revies }
    end
  end
end
