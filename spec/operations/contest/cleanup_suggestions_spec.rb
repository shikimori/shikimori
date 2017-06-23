describe Contest::CleanupSuggestions do
  let(:operation) { Contest::CleanupSuggestions.new contest }

  let(:contest) { create :contest, :proposing }
  let!(:contest_suggestion_1) { create :contest_suggestion, contest: contest, user: contest.user }
  let!(:contest_suggestion_2) { create :contest_suggestion, contest: contest, user: create(:user, sign_in_count: 999) }

  subject! { operation.call }

  it { expect(contest.suggestions).to eq [contest_suggestion_2] }
end
