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
    let(:view_contex) { double "can?": can_manage, "current_user": (double staff?: is_staff) }
    let(:can_manage) { [true, false].sample }
    let(:is_staff) { false }

    it do
      is_expected.to eq can_manage
      expect(view_contex).to have_received(:"can?").with(:"manage_#{role}_role", User)
    end

    context 'staff has access' do
      let(:can_manage) { false }
      let(:is_staff) { [true, false].sample }

      it { is_expected.to eq is_staff }
    end
  end
end
