describe VersionsPolicy do
  subject { described_class.change_allowed? version, user }

  let(:version) { build :version, item: item, item_diff: item_diff, user: author }
  let(:author) { user }
  let(:user) { seed :user }

  let(:item) { build_stubbed :anime }
  let(:item_diff) do
    {
      russian: ['История финала 2', 'История финала 22']
    }
  end

  it { is_expected.to eq true }

  context 'user banned' do
    before { user.read_only_at = 1.hour.from_now }
    it { is_expected.to eq false }
  end

  context 'not_trusted_version_changer' do
    before { user.roles = %i[not_trusted_version_changer] }
    it { is_expected.to eq false }
  end

  context 'not matched author' do
    let(:author) { user_2 }
    it { is_expected.to eq false }
  end
end
