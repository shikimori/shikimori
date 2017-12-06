describe Recommendations::ExcludedIds do
  include_context :seeds

  let(:animes) { create_list :anime, 7 }
  let!(:user_rate_planned) { create :user_rate, :planned, target: animes[0], user: user }
  let!(:user_rate_watching) { create :user_rate, :watching, target: animes[1], user: user }
  let!(:user_rate_rewatching) { create :user_rate, :rewatching, target: animes[2], user: user }
  let!(:user_rate_completed) { create :user_rate, :completed, target: animes[3], user: user }
  let!(:user_rate_on_hold) { create :user_rate, :on_hold, target: animes[4], user: user }
  let!(:user_rate_dropped) { create :user_rate, :dropped, target: animes[5], user: user }
  let!(:user_rate_planned_2) { create :user_rate, :planned, target: animes[6], user: create(:user) }

  subject! { described_class.call user, 'anime' }

  it do
    is_expected.to eq [
      user_rate_watching.target_id,
      user_rate_rewatching.target_id,
      user_rate_completed.target_id,
      user_rate_on_hold.target_id,
      user_rate_dropped.target_id
    ].sort
  end
end
