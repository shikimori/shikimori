describe RolesPolicy do
  subject { described_class.accessible? role }

  context 'not restricted role' do
    let(:role) { ['admin', :admin].sample }
    it { is_expected.to eq true }
  end

  context 'restricted role' do
    let(:role) { described_class::RESTRICTED_ROLES.sample }
    before do
      allow_any_instance_of(described_class)
        .to receive(:h)
        .and_return view_contex
    end
    let(:view_contex) { double "can?": can_manage }
    let(:can_manage) { [true, false].sample }

    it do
      is_expected.to eq can_manage
      expect(view_contex).to have_received(:"can?").with(:"manage_#{role}_role", User)
    end
  end
end
