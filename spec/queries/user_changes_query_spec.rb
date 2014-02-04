require 'spec_helper'

describe UserChangesQuery do
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:user4) { create :user }

  let(:entry) { create :character }
  let(:entry2) { create :character }

  before do
    create :user_change, model: 'character', column: 'description', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'character', column: 'description', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'character', column: 'description', item_id: entry.id, user_id: user2.id, status: UserChangeStatus::Taken
    create :user_change, model: 'anime', column: 'description', item_id: entry.id, user_id: user3.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'character', column: 'name', item_id: entry.id, user_id: user4.id, status: UserChangeStatus::Accepted
    create :user_change, model: 'character', column: 'description', item_id: entry.id, user_id: user4.id, status: UserChangeStatus::Pending
    @lock = create :user_change, model: 'character', column: 'description', item_id: entry.id, user_id: user4.id, status: UserChangeStatus::Locked
    1.upto(2) { create :user_change, model: 'character', column: 'video', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Taken }
    create :user_change, model: 'character', column: 'screenshots', item_id: entry.id, user_id: user.id, status: UserChangeStatus::Taken
  end

  describe 'fetch' do
    it { UserChangesQuery.new(entry, 'description').fetch.should have(4).items }
    it { UserChangesQuery.new(entry, :name).fetch.should have(1).items }
    it { UserChangesQuery.new(entry, :video).fetch.should have(2).items }
    it { UserChangesQuery.new(entry, :screenshots).fetch.should have(1).items }
  end

  describe 'authors' do
    it { UserChangesQuery.new(entry, 'description').authors.should have(2).items }
    it { UserChangesQuery.new(entry, 'description').authors(false).should have(1).item }
    it { UserChangesQuery.new(entry, :name).authors.should have(1).items }
  end

  describe 'lock' do
    it { UserChangesQuery.new(entry, 'description').lock.should eql @lock }
    it { UserChangesQuery.new(entry2, 'description').lock.should be_nil }
  end
end

