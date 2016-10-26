describe Style do
  describe 'relations' do
    it { is_expected.to belong_to :owner }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :owner }
  end

  describe 'instance methods' do
    describe '#safe_css' do
      let(:style) { build :style, css: 'body { color: red; }; javascript:blablalba;;' }
      it { expect(style.safe_css).to eq 'body { color: red; }; :blablalba;' }
    end
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'owner' do
      let(:style) { build_stubbed :style, owner: user }

      context 'not style of owner' do
        it { is_expected.to be_able_to :create, style }
        it { is_expected.to be_able_to :update, style }
        it { is_expected.to be_able_to :destroy, style }
      end

      context 'style of owner' do
        before { user.style = style }

        it { is_expected.to be_able_to :create, style }
        it { is_expected.to be_able_to :update, style }
        it { is_expected.to_not be_able_to :destroy, style }
      end
    end

    context 'guest' do
      let(:style) { build_stubbed :style }
      let(:user) { nil }

      it { is_expected.to_not be_able_to :create, style }
      it { is_expected.to_not be_able_to :update, style }
      it { is_expected.to_not be_able_to :destroy, style }
    end

    context 'user' do
      let(:style) { build_stubbed :style }
      let(:user) { nil }

      it { is_expected.to_not be_able_to :create, style }
      it { is_expected.to_not be_able_to :update, style }
      it { is_expected.to_not be_able_to :destroy, style }
    end
  end
end
