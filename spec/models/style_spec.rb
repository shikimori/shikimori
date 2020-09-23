describe Style do
  describe 'relations' do
    it { is_expected.to belong_to(:owner).without_validating_presence }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :owner }
  end

  describe 'instance methods' do
    describe '#css=' do
      let(:style) { build :style, css: 'z', compiled_css: 'x', imports: [] }
      subject! { style.css = 'y' }

      it do
        expect(style.css).to eq 'y'
        expect(style.compiled_css).to be_nil
        expect(style.imports).to be_nil
      end
    end

    describe '#compile!' do
      include_context :timecop
      let(:style) { build :style, css: css, created_at: 1.hour.ago, updated_at: 1.hour.ago }
      let(:css) { '/* test */ a { color: red; }' }

      subject { style.compile! }
      let(:compiled_style) do
        '/* ' + Styles::Compile::USER_CONTENT + " */\n" + Styles::Compile::MEDIA_QUERY_CSS +
          " {\na { color: red; }\n}"
      end

      it do
        is_expected.to eq compiled_style
        expect(style.reload.compiled_css).to eq compiled_style
        expect(style.updated_at).to be_within(0.1).of Time.zone.now
      end
    end

    describe '#compiled?' do
      subject { build :style, css: css, compiled_css: compiled_css }

      context 'has css, has compiled_css' do
        let(:css) { 'zxc' }
        let(:compiled_css) { 'cvb' }

        it { is_expected.to be_compiled }
      end

      context 'has css, no compiled_css' do
        let(:css) { 'zxc' }
        let(:compiled_css) { nil }

        it { is_expected.to_not be_compiled }
      end

      context 'no css, no compiled_css' do
        let(:css) { nil }
        let(:compiled_css) { nil }

        it { is_expected.to be_compiled }
      end
    end
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'owner' do
      context 'user' do
        let(:style) { build_stubbed :style, owner: user }

        context 'not style of owner' do
          it { is_expected.to be_able_to :show, style }
          it { is_expected.to be_able_to :preview, style }
          it { is_expected.to be_able_to :create, style }
          it { is_expected.to be_able_to :update, style }
          it { is_expected.to_not be_able_to :destroy, style }
        end

        context 'style of owner' do
          before { user.style = style }

          it { is_expected.to be_able_to :show, style }
          it { is_expected.to be_able_to :preview, style }
          it { is_expected.to be_able_to :create, style }
          it { is_expected.to be_able_to :update, style }
          it { is_expected.to_not be_able_to :destroy, style }
        end
      end

      context 'club' do
        let(:style) { build_stubbed :style, owner: club }
        let(:club) { build_stubbed :club, member_roles: [club_role] }

        context 'not club admin' do
          let(:club_role) { build_stubbed :club_role, :member, user: user }

          it { is_expected.to be_able_to :show, style }
          it { is_expected.to be_able_to :preview, style }
          it { is_expected.to_not be_able_to :create, style }
          it { is_expected.to_not be_able_to :update, style }
          it { is_expected.to_not be_able_to :destroy, style }
        end

        context 'club admin' do
          let(:club_role) { build_stubbed :club_role, :admin, user: user }

          it { is_expected.to be_able_to :show, style }
          it { is_expected.to be_able_to :preview, style }
          it { is_expected.to be_able_to :create, style }
          it { is_expected.to be_able_to :update, style }
          it { is_expected.to_not be_able_to :destroy, style }
        end
      end
    end

    context 'guest' do
      let(:style) { build_stubbed :style }
      let(:user) { nil }

      it { is_expected.to be_able_to :show, style }
      it { is_expected.to be_able_to :preview, style }
      it { is_expected.to_not be_able_to :create, style }
      it { is_expected.to_not be_able_to :update, style }
      it { is_expected.to_not be_able_to :destroy, style }
    end

    context 'user' do
      let(:style) { build_stubbed :style }
      let(:user) { nil }

      it { is_expected.to be_able_to :show, style }
      it { is_expected.to be_able_to :preview, style }
      it { is_expected.to_not be_able_to :create, style }
      it { is_expected.to_not be_able_to :update, style }
      it { is_expected.to_not be_able_to :destroy, style }
    end
  end
end
