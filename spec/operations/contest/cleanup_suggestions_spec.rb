describe Contest::CleanupSuggestions do
  let(:operation) { Contest::CleanupSuggestions.new contest }

  let(:contest) { create :contest, :proposing }
  let!(:normal_suggestion) do
    create :contest_suggestion,
      contest: contest,
      user: contest.user
  end
  let!(:suspicious_suggestion) do
    create :contest_suggestion,
      contest: contest,
      user: create(:user, :suspicious)
  end

  subject! { operation.call }

  it { expect(contest.suggestions).to eq [normal_suggestion] }
end
