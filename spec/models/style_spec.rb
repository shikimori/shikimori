describe Style do
  describe 'relations' do
    it { is_expected.to belong_to(:owner).without_validating_presence }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :owner }
  end

  describe 'instance methods' do
    describe '#compiled_css' do
      let(:style) { build :style, css: css }

      context '#strip_comments' do
        let(:css) { '/* test */ test' }
        it { expect(style.compiled_css).to eq "#{Style::MEDIA_QUERY_CSS} { test }" }
      end

      context '#camo_images' do
        let(:image_url) { 'http://s8.hostingkartinok.com/uploads/images/2016/02/87303db8016e56e8a9eeea92f81f5760.jpg' }
        let(:quote) { ['"', "'", '`', ''].sample }
        let(:css) { "body { background: url(#{quote}#{image_url}#{quote}); };" }

        it do
          expect(style.compiled_css).to eq(
            <<-CSS.squish
              #{Style::MEDIA_QUERY_CSS} {
                body {
                  background: url(#{quote}#{UrlGenerator.instance.camo_url image_url}#{quote});
                };
              }
            CSS
          )
        end
      end

      context '#sanitize' do
        let(:css) { 'body { color: red; }; javascript:blablalba;;' }
        it { expect(style.compiled_css).to eq "#{Style::MEDIA_QUERY_CSS} { body { color: red; }; :blablalba; }" }
      end

      describe '#media_query' do
        context 'with styles' do
          context 'with media' do
            let(:css) { '@media only screen and (min-width: 100px) { test }' }
            it { expect(style.compiled_css).to eq css }
          end

          context 'without media' do
            let(:css) { 'test' }
            it { expect(style.compiled_css).to eq "#{Style::MEDIA_QUERY_CSS} { test }" }
          end
        end

        context 'without styles' do
          let(:css) { '' }
          it { expect(style.compiled_css).to eq '' }
        end
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
