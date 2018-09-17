describe Versions::RoleVersion do
  describe '#action' do
    let(:version) { build :role_version, item_diff: { action: 'add' } }
    it { expect(version.action).to eq Versions::RoleVersion::Actions[:add] }
  end

  describe '#role' do
    let(:version) { build :role_version, item_diff: { role: 'super_moderator' } }
    it { expect(version.role).to eq Types::User::Roles[:super_moderator] }
  end

  describe '#apply_changes' do
    let(:version) do
      build :role_version,
        item: user_admin,
        item_diff: {
          action: action,
          role: role
        }
    end

    context 'add' do
      let(:action) { Versions::RoleVersion::Actions[:add] }
      let(:role) { Types::User::Roles[:super_moderator] }
      subject! { version.apply_changes }

      it { expect(user_admin.reload).to be_super_moderator }
    end

    context 'remove' do
      let(:action) { Versions::RoleVersion::Actions[:remove] }
      let(:role) { Types::User::Roles[:admin] }
      subject! { version.apply_changes }

      it { expect(user_admin.reload).to_not be_admin }
    end
  end

  describe '#rollback_changes' do
    let(:version) do
      build :role_version,
        item: user_admin,
        item_diff: {
          action: action,
          role: role
        }
    end

    context 'add' do
      let(:action) { Versions::RoleVersion::Actions[:add] }
      let(:role) { Types::User::Roles[:admin] }
      subject! { version.rollback_changes }

      it { expect(user_admin.reload).to_not be_admin }
    end

    context 'remove' do
      let(:action) { Versions::RoleVersion::Actions[:remove] }
      let(:role) { Types::User::Roles[:super_moderator] }
      subject! { version.rollback_changes }

      it { expect(user_admin.reload).to be_super_moderator }
    end
  end
end
