# TODO: удалить после миграция UserChange на Version
describe UserChangesQuery do
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:user4) { create :user }

  let(:entry) { create :character }
  let(:entry2) { create :character }

  before do
    create :user_change, model: 'Character', column: 'description', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'Character', column: 'description', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'Character', column: 'description', item_id: entry.id, user_id: user2.id, status: UserChangeStatus::Taken
    create :user_change, model: 'Anime', column: 'description', item_id: entry.id, user_id: user3.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'Character', column: 'name', item_id: entry.id, user_id: user4.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'Character', column: 'description', item_id: entry.id, user_id: user4.id, status: UserChangeStatus::Pending
    1.upto(2) { create :user_change, model: 'Character', column: 'video', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Taken }
    create :user_change, model: 'Character', column: 'screenshots', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Taken
  end

  describe 'fetch' do
    it { expect(UserChangesQuery.new(entry, 'description').fetch.size).to eq(4) }
    it { expect(UserChangesQuery.new(entry, :name).fetch.size).to eq(1) }
    it { expect(UserChangesQuery.new(entry, :video).fetch.size).to eq(2) }
    it { expect(UserChangesQuery.new(entry, :screenshots).fetch.size).to eq(1) }
  end

  describe 'authors' do
    it { expect(UserChangesQuery.new(entry, 'description').authors.size).to eq(2) }
    it { expect(UserChangesQuery.new(entry, 'description').authors(false).size).to eq(1) }
    it { expect(UserChangesQuery.new(entry, :name).authors.size).to eq(1) }

    context 'video' do
      let(:anime) { build_stubbed :anime }
      let!(:video_1) { create :video, :confirmed, anime: anime, uploader: user4 }
      let!(:video_2) { create :video, :deleted, anime: anime, uploader: user4 }
      let!(:user_change_11) { create :user_change, model: Anime.name, column: 'video', item_id: anime.id, value: video_1.id, user: user3, status: UserChangeStatus::Accepted }
      let!(:user_change_12) { create :user_change, model: Anime.name, column: 'video', item_id: anime.id, value: video_2.id, user: user2, status: UserChangeStatus::Accepted }

      it { expect(UserChangesQuery.new(anime, 'video').authors).to eq [user3] }
    end
  end
end
