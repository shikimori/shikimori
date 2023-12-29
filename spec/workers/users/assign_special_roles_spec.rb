describe Users::AssignSpecialRoles do
  let(:worker) { described_class.new }
  before do
    stub_const 'Users::AssignSpecialRoles::MIN_USER_RATES_IN_LIST', 2
    stub_const 'Users::AssignSpecialRoles::MIN_AI_TITLES_IN_LIST', 2
  end
  include_context :reset_repository, AnimeGenresV2Repository
  include_context :reset_repository, MangaGenresV2Repository

  let!(:user_rate_1_1) do
    create :user_rate, user: user_1, status: :completed, target: anime_1
  end
  let!(:user_rate_1_2) do
    create :user_rate, user: user_1, status: :planned, target: anime_2
  end
  let!(:user_rate_2_1) do
    create :user_rate, user: user_2, status: :completed, target: anime_1
  end
  let!(:user_rate_2_3) do
    create :user_rate, user: user_2, status: :completed, target: anime_3
  end
  let!(:user_rate_3_1) do
    create :user_rate, user: user_3, status: :completed, target: anime_1
  end

  let(:anime_1) { create :anime, genre_v2_ids: [ai_genre.id] }
  let(:anime_2) { create :anime, genre_v2_ids: [ai_genre.id] }
  let(:anime_3) { create :anime, genre_v2_ids: [not_ai_genre.id] }

  let(:ai_genre) { create :genre_v2, id: GenreV2::SHOUJO_AI_IDS.sample }
  let(:not_ai_genre) { create :genre_v2, id: 999999 }

  subject! { worker.perform }

  it do
    expect(user_1.reload).to be_ai_genres
    expect(user_2.reload).to_not be_ai_genres
    expect(user_3.reload).to_not be_ai_genres
  end
end
