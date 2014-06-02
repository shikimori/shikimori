require 'spec_helper'

describe UserListQuery do
  let(:query) { UserListQuery.new Anime, user, params }
  let(:user) { create :user }
  let(:params) {{ mylist: '1,2', order: 'name' }}

  let!(:user_rate_1) { create :user_rate, user: user, anime: create(:anime, name: 'b'), status: 1 }
  let!(:user_rate_2) { create :user_rate, user: user, anime: create(:anime, name: 'a'), status: 1 }
  let!(:user_rate_3) { create :user_rate, user: user, anime: create(:anime), status: 2 }
  let!(:user_rate_4) { create :user_rate, user: user, anime: create(:anime), status: 3 }

  subject { query.fetch }

  it { should have(2).items }
  its(:first) { should eq [:watching, [user_rate_2, user_rate_1]] }
  its([:completed]) { should eq [user_rate_3] }
end
