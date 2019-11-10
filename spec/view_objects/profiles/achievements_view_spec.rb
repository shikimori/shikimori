describe Profiles::AchievementsView do
  let(:view) { described_class.new user }

  let!(:animelist_1) do
    create :achievement, user: user, neko_id: :animelist, level: 1
  end
  let!(:animelist_2) do
    create :achievement, user: user, neko_id: :animelist, level: 2
  end
  let!(:otaku) do
    create :achievement, user: user, neko_id: :otaku, level: 1
  end
  let!(:historical) do
    create :achievement, user: user, neko_id: :historical, level: 1
  end

  let!(:ghost_in_the_shell) do
    create :achievement, user: user, neko_id: :ghost_in_the_shell, level: 0
  end
  let!(:ghost_in_the_shell) do
    create :achievement, user: user, neko_id: :ghost_in_the_shell, level: 1
  end

  let!(:tetsurou_araki) do
    create :achievement, user: user, neko_id: :tetsurou_araki, level: 0
  end
  let!(:tetsurou_araki) do
    create :achievement, user: user, neko_id: :tetsurou_araki, level: 1
  end
  let!(:tensai_okamura) do
    create :achievement, user: user, neko_id: :tensai_okamura, level: 0
  end
  let!(:tensai_okamura) do
    create :achievement, user: user, neko_id: :tensai_okamura, level: 1
  end

  it { expect(view.common_achievements).to eq [animelist_2, otaku] }
  it { expect(view.genre_achievements).to eq [historical] }

  it { expect(view.franchise_achievements).to eq [ghost_in_the_shell] }
  it { expect(view.franchise_achievements_size).to eq 1 }
  it { expect(view.all_franchise_achievements).to have_at_least(160).items }
  it { expect(view.missing_franchise_achievements).to have(3).items }

  it { expect(view.author_achievements).to eq [tetsurou_araki, tensai_okamura] }
  it { expect(view.author_achievements_size).to eq 2 }
  it { expect(view.all_author_achievements).to have_at_least(43).items }
  it { expect(view.missing_author_achievements).to have(2).items }
end
