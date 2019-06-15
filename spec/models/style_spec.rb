describe Style do
  describe 'relations' do
    it { is_expected.to belong_to(:owner).without_validating_presence }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :owner }
  end

  describe 'instance methods' do
    describe '#compiled_css' do
      include_context :timecop
      let(:style) { build :style, css: css, created_at: 1.hour.ago, updated_at: 1.hour.ago }
      let(:css) { '/* test */ test' }

      it do
        expect(style.compiled_css).to eq "#{Styles::Compile::MEDIA_QUERY_CSS} { test }"
        expect(style.reload.attributes['compiled_css']).to eq(
          "#{Styles::Compile::MEDIA_QUERY_CSS} { test }"
        )
        expect(style.updated_at).to be_within(0.1).of Time.zone.now
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
