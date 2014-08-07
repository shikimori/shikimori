require 'spec_helper'

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
    @lock = create :user_change, model: 'Character', column: 'description', item_id: entry.id, user_id: user4.id, status: UserChangeStatus::Locked
    1.upto(2) { create :user_change, model: 'Character', column: 'video', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Taken }
    create :user_change, model: 'Character', column: 'screenshots', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Taken
  end

  describe :fetch do
    it { expect(UserChangesQuery.new(entry, 'description').fetch).to have(4).items }
    it { expect(UserChangesQuery.new(entry, :name).fetch).to have(1).items }
    it { expect(UserChangesQuery.new(entry, :video).fetch).to have(2).items }
    it { expect(UserChangesQuery.new(entry, :screenshots).fetch).to have(1).items }
  end

  describe :authors do
    it { expect(UserChangesQuery.new(entry, 'description').authors).to have(2).items }
    it { expect(UserChangesQuery.new(entry, 'description').authors(false)).to have(1).item }
    it { expect(UserChangesQuery.new(entry, :name).authors).to have(1).items }

    context :video do
      let(:anime) { build_stubbed :anime }
      let!(:video_1) { create :video, :confirmed, anime: anime, uploader: user4 }
      let!(:video_2) { create :video, :deleted, anime: anime, uploader: user4 }
      let!(:user_change_11) { create :user_change, model: Anime.name, column: 'video', item_id: anime.id, value: video_1.id, user: user3, status: UserChangeStatus::Accepted }
      let!(:user_change_12) { create :user_change, model: Anime.name, column: 'video', item_id: anime.id, value: video_2.id, user: user2, status: UserChangeStatus::Accepted }

      it { expect(UserChangesQuery.new(anime, 'video').authors).to eq [user3] }
    end
  end

  describe :lock do
    it { expect(UserChangesQuery.new(entry, 'description').lock).to eql @lock }
    it { expect(UserChangesQuery.new(entry2, 'description').lock).to be_nil }
  end
end

