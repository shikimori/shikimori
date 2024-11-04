describe Users::AssignSpecialRoles do
  let(:worker) { described_class.new }
  let(:current_date) { Time.zone.today }

  context 'ai_geners' do
    before do
      stub_const 'Users::AssignSpecialRoles::MIN_USER_RATES_IN_LIST', 2
      stub_const 'Users::AssignSpecialRoles::MIN_AI_TITLES_IN_LIST', 2
    end
    # include_context :reset_repository, AnimeGenresV2Repository
    # include_context :reset_repository, MangaGenresV2Repository

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

    let(:ai_genre) do
      create :genre_v2,
        id: (
          GenreV2::SHOUJO_AI_IDS + GenreV2::SHOUNEN_AI_IDS +
            GenreV2::YAOI_IDS + GenreV2::YURI_IDS
        ).sample
    end
    let(:not_ai_genre) { create :genre_v2, id: 999999 }

    subject! { worker.perform current_date.to_s }

    it do
      expect(user_1.reload).to be_ai_genres
      expect(user_2.reload).to_not be_ai_genres
      expect(user_3.reload).to_not be_ai_genres
    end
  end

  context 'mass_registration' do
    let!(:user_1) { create :user, current_sign_in_ip: '1.1.1.1' }
    let!(:user_2) { create :user, current_sign_in_ip: '1.1.1.1' }
    let!(:user_3) { create :user, current_sign_in_ip: '1.1.1.1' }

    let!(:user_11) { create :user, current_sign_in_ip: '1.1.1.2' }
    let!(:user_12) { create :user, current_sign_in_ip: '1.1.1.2' }
    let!(:user_13) do
      create :user,
        current_sign_in_ip: '1.1.1.2',
        created_at: described_class::MASS_REGISTRATION_INTERVAL.ago - 1.day
    end

    subject! { worker.perform current_date.to_s }

    it do
      expect(user_1.reload).to be_mass_registration
      expect(user_2.reload).to be_mass_registration
      expect(user_3.reload).to be_mass_registration

      expect(user_11.reload).to_not be_mass_registration
      expect(user_12.reload).to_not be_mass_registration
      expect(user_13.reload).to_not be_mass_registration
    end
  end

  context 'permaban' do
    let!(:user_1) do
      create :user,
        read_only_at: described_class::PERMABAN_INTERVAL.from_now + 1.day
    end
    let!(:user_2) do
      create :user,
        read_only_at: described_class::PERMABAN_INTERVAL.from_now - 1.day
    end

    subject! { worker.perform current_date.to_s }

    it do
      expect(user_1.reload).to be_permaban
      expect(user_2.reload).to_not be_permaban
    end
  end
end
