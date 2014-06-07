require 'spec_helper'

describe GroupBan do
  context :relations do
    it { should belong_to :group }
    it { should belong_to :user }
  end

  context :validations do
    it { should validate_presence_of :group }
    it { should validate_presence_of :user }
  end

  describe :callbacks do
    let(:user) { create :user }
    let!(:group) { create :group }
    let!(:group_role) { create :group_role, user: user, group: group }

    before { create :group_ban, group: group, user: user }
    it { expect(group.member? user).to be false }
  end
end
