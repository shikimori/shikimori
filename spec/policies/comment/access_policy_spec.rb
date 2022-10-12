describe Comment::AccessPolicy do
  subject { described_class.allowed? comment, decorated_user }

  let(:comment) do
    build_stubbed :comment,
      user: comment_user,
      commentable: commentable
  end
  let(:decorated_user) { [user.decorate, nil].sample }
  let(:comment_user) { user_2 }
  before do
    allow(Topic::AccessPolicy)
      .to receive(:allowed?)
      .with(commentable, decorated_user)
      .and_return is_allowed
  end
  let(:commentable) { build_stubbed :topic }
  let(:is_allowed) { [true, false].sample }

  describe 'user' do
    context 'guest' do
      let(:decorated_user) { nil }
      it { is_expected.to eq is_allowed }
    end

    context 'moderator' do
      let(:comment_user) { user }
      let(:decorated_user) { user.decorate }
      before { allow(decorated_user).to receive(:moderation_staff?).and_return true }

      it { is_expected.to eq true }
    end

    context 'user' do
      let(:decorated_user) { nil }

      context "user's own comment" do
        let(:comment_user) { user }
        let(:decorated_user) { user.decorate }
        let(:is_allowed) { false }

        it { is_expected.to eq true }
      end

      context "other user's comment" do
        describe 'commentable' do
          context 'user' do
            let(:commentable) { user_2 }

            context 'common user' do
              it { is_expected.to eq true }
            end

            context 'user with disabled profile comments' do
              let(:commentable) do
                build_stubbed :user,
                  preferences: build_stubbed(:user_preferences, comments_in_profile: false)
              end
              it { is_expected.to eq false }
            end

            context 'user with censored_profile' do
              let(:commentable) { build_stubbed :user, roles: %i[censored_profile] }
              it { is_expected.to eq false }
            end
          end

          context 'topic' do
            let(:commentable) { build_stubbed :topic }
            it { is_expected.to eq is_allowed }
          end
        end
      end
    end
  end
end
