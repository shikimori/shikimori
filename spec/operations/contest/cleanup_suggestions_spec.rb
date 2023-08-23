describe Contest::CleanupSuggestions do
  let!(:normal_suggestion) do
    create :contest_suggestion,
      contest: contest,
      item: allowed_item,
      user: contest.user
  end
  let!(:forbidden_suggestion) do
    create :contest_suggestion,
      contest: contest,
      item: forbidden_item,
      user: contest.user
  end
  let!(:suspicious_suggestion) do
    create :contest_suggestion,
      contest: contest,
      item: allowed_item,
      user: create(:user, :suspicious)
  end

  subject! { described_class.call contest }

  let(:contest) { create :contest, :proposing, contest_type }
  let(:forbidden_item) { create contest_type, name: 'Pico' }
  let(:allowed_item) { create contest_type, name: 'Not Pico' }

  context 'character' do
    let(:contest_type) { :character }
    it { expect(contest.suggestions).to eq [normal_suggestion] }
  end

  context 'anime' do
    let(:contest_type) { :anime }
    it { expect(contest.suggestions.sort_by(&:id)).to eq [normal_suggestion, forbidden_suggestion] }
  end
end
