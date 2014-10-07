require 'spec_helper'

describe GroupRolesQuery do
  describe :complete do
    let(:club) { create :group, owner: user_2 }
    let!(:group_role_1) { create :group_role, group: club, user: user_1 }
    let!(:group_role_2) { create :group_role, group: club, user: user_2 }
    let!(:group_role_3) { create :group_role, group: club, user: user_3 }

    let(:user_1) { create :user, nickname: 'morr' }
    let(:user_2) { create :user, nickname: 'morrrr' }
    let(:user_3) { create :user, nickname: 'zzzz' }
    let(:user_4) { create :user, nickname: 'xxxx' }

    let(:query) { GroupRolesQuery.new(club) }

    it { query.complete('mo').should eq [user_1, user_2] }
    it { query.complete('morrr').should eq [user_2] }
  end
end
