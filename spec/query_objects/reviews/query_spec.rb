describe Reviews::Query do
  before do
    Review.wo_antispam do
      @reviews = [
        create(:review, anime: db_entry, user: user_1),
        create(:review, anime: db_entry, user: user_2, created_at: Reviews::Query::NEW_REVIEW_BUBBLE_INTERVAL.ago),
        create(:review, anime: db_entry, user: user_3),
        create(:review, anime: anime, user: user_1)
      ]
    end
  end

  let(:db_entry) { create :anime }
  let(:anime) { create :anime }

  subject { described_class.call db_entry }

  it { is_expected.to eq [@reviews[2], @reviews[0], @reviews[1]] }
end
