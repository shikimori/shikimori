describe Users::MarkAsCompletedAnnouncedAnimes do
  let!(:user_4) { create :user, roles: %i[completed_announced_animes] }

  let!(:user_rate_1_1) do
    create :user_rate, user: user_1, status: :completed, target: anime_1
  end
  let!(:user_rate_1_2) do
    create :user_rate, user: user_1, status: :planned, target: anime_2
  end
  let!(:user_rate_2_1) do
    create :user_rate, user: user_2, status: :completed, target: anime_1
  end
  let!(:user_rate_2_2) do
    create :user_rate, user: user_2, status: :completed, target: anime_2
  end
  let!(:user_rate_3_1) do
    create :user_rate, user: user_3, status: :completed, target: anime_3
  end
  let!(:user_rate_3_2) do
    create :user_rate, user: user_3, status: :completed, target: anime_4
  end
  let(:anime_1) { create :anime, status: :anons }
  let(:anime_2) { create :anime, status: :anons }
  let(:anime_3) { create :anime, status: :ongoing }
  let(:anime_4) { create :anime, status: :ongoing }

  subject! { described_class.new.perform }

  it do
    expect(user_1.reload).to_not be_completed_announced_animes
    expect(user_2.reload).to be_completed_announced_animes
    expect(user_3.reload).to_not be_completed_announced_animes
    expect(User.find(user_4.id)).to_not be_completed_announced_animes
  end
end
