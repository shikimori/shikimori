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

  it do
    is_expected.to have(3).items
    expect(subject.last).to eq @reviews[1]
    expect(subject.first).to eq @reviews[2]
  end
end
