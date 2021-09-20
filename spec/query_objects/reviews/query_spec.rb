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

  subject { described_class.call db_entry, opinion: opinion }

  context 'no opinion' do
    let(:opinion) { ['', nil].sample }
    it { is_expected.to eq [@reviews[2], @reviews[0], @reviews[1]] }
  end

  context 'has opinion' do
    let(:opinion) { :positive }
    it { is_expected.to eq [@reviews[0], @reviews[1]] }
  end
end
