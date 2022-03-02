# frozen_string_literal: true

describe Club do
  describe 'relations' do
    it { is_expected.to have_many(:member_roles).dependent(:destroy) }
    it { is_expected.to have_many :members }

    # it { is_expected.to have_many :moderator_roles }
    # it { is_expected.to have_many :moderators }

    it { is_expected.to have_many :admin_roles }
    it { is_expected.to have_many :admins }

    it { is_expected.to have_many(:pages).dependent(:destroy) }
    # it { is_expected.to have_many :root_pages }
    it { is_expected.to have_many(:links).dependent(:destroy) }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :ranobe }
    it { is_expected.to have_many :characters }
    it { is_expected.to have_many :clubs }
    it { is_expected.to have_many :collections }

    it { is_expected.to have_many(:images).dependent(:destroy) }

    it { is_expected.to belong_to :owner }

    it { is_expected.to have_many(:invites).dependent(:destroy) }
    it { is_expected.to have_many(:bans).dependent(:destroy) }
    it { is_expected.to have_many :banned_users }

    it { is_expected.to belong_to(:style).optional }
    it { is_expected.to have_many(:styles).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to have_attached_file :logo }
    it { is_expected.to validate_presence_of :locale }
    it { is_expected.to validate_length_of(:description).is_at_most(150_000) }
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:join_policy)
        .in(*Types::Club::JoinPolicy.values)
      is_expected
        .to enumerize(:comment_policy)
        .in(*Types::Club::CommentPolicy.values)
      is_expected
        .to enumerize(:topic_policy)
        .in(*Types::Club::TopicPolicy.values)
      is_expected
        .to enumerize(:page_policy)
        .in(*Types::Club::PagePolicy.values)
      is_expected
        .to enumerize(:image_upload_policy)
        .in(*Types::Club::ImageUploadPolicy.values)
      is_expected.to enumerize(:locale).in(*Types::Locale.values)
    end
  end

  describe 'callbacks' do
    describe '#join_owner' do
      let(:club) { create :club, :with_owner_join }
      it { expect(club.member? club.owner).to eq true }
    end

    describe '#assign_style' do
      let(:club) { create :club, :with_assign_style }
      it do
        expect(club.reload.style).to be_persisted
        expect(club.style).to have_attributes(
          css: '',
          name: ''
        )
        expect(club.styles.first).to eq club.style
        expect(club.styles).to have(1).item
      end
    end

    describe '#check_spam_abuse' do
      before { allow(Users::CheckHacked).to receive(:call).and_return true }
      let!(:club) { create :club }

      it do
        expect(Users::CheckHacked)
          .to have_received(:call)
          .with(
            model: club,
            user: club.owner,
            text: club.description
          )
      end
    end
  end

  describe 'instance methods' do
    describe '#to_param' do
      let(:club) { build :club, id: 1, name: 'тест' }
      it { expect(club.to_param).to eq '1-test' }
    end

    describe '#name=' do
      let(:club) { build :club, name: name }
      let(:name) { '#[test]%&?+@' }

      it { expect(club.name).to eq FixName.call(name, false) }
    end

    describe '#private?' do
      before do
        subject.is_censored = is_censored
        subject.join_policy = join_policy
        subject.comment_policy = comment_policy
      end
      let(:is_censored) { true }
      let(:join_policy) { (Types::Club::JoinPolicy.values - %i[free]).sample }
      let(:comment_policy) { (Types::Club::CommentPolicy.values - %i[free]).sample }

      it { is_expected.to be_private }

      context 'not censored' do
        let(:is_censored) { false }
        it { is_expected.to_not be_private }
      end

      context 'free join_policy' do
        let(:join_policy) { Types::Club::JoinPolicy[:free] }
        it { is_expected.to_not be_private }
      end

      context 'not censored' do
        let(:comment_policy) { Types::Club::JoinPolicy[:free] }
        it { is_expected.to_not be_private }
      end
    end

    describe '#member?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.member? user }

      context 'owner' do
        let(:club) { build_stubbed :club, owner: user }
        it { is_expected.to be false }
      end

      context 'admin' do
        let(:club) do
          build_stubbed :club,
            member_roles: [build_stubbed(:club_role, :member, user: user)]
        end
        it { is_expected.to be true }
      end

      context 'not a member' do
        it { is_expected.to be false }
      end
    end

    describe '#admin?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.admin? user }

      context 'just owner' do
        let(:club) { build_stubbed :club, owner: user }
        it { is_expected.to be false }
      end

      context 'is admin' do
        let(:club) do
          build_stubbed :club,
            member_roles: [build_stubbed(:club_role, :admin, user: user)]
        end
        it { is_expected.to be true }
      end

      context 'not a member' do
        it { is_expected.to be false }
      end
    end

    describe '#owner?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.owner? user }

      context 'is owner' do
        let(:club) { build_stubbed :club, owner: user }
        it { is_expected.to be true }
      end

      context 'not an owner' do
        it { is_expected.to be false }
      end
    end

    describe '#invited?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.invited? user }

      context 'invited' do
        let(:club) do
          build_stubbed :club,
            invites: [build_stubbed(:club_invite, dst: user)]
        end
        it { is_expected.to be true }
      end

      context 'not invited' do
        it { is_expected.to be false }
      end
    end

    describe '#member_role' do
      let(:user) { build_stubbed :user }
      let(:club) { build_stubbed :club, member_roles: [club_role] }
      let(:club_role) { build_stubbed :club_role, user: user }
      subject { club.member_role user }

      it { is_expected.to eq club_role }
    end

    describe '#ban' do
      let(:user) { create :user }
      before { club.ban user }

      it { expect(club.banned? user).to be true }
    end

    describe '#join' do
      let(:user) { create :user }
      before { club.join user }

      it { expect(club.reload.club_roles_count).to eq 1 }
      it { expect(club.member? user).to be true }

      context 'user' do
        it { expect(club.admin? user).to eq false }
      end

      context 'club_owner' do
        let(:club) { create :club, owner: user }
        it { expect(club.admin? user).to eq true }
      end

      describe '#leave' do
        before { club.reload.leave user }

        it { expect(club.member? user).to be false }
        it { expect(club.reload.club_roles_count).to be_zero }
      end
    end
  end

  describe 'permissions' do
    let(:club) { build_stubbed :club, join_policy: join_policy }
    let(:user) { build_stubbed :user, :user, :week_registered }
    let(:join_policy) { Types::Club::JoinPolicy[:free] }
    let(:topic_policy) { Types::Club::TopicPolicy[:members] }

    subject { Ability.new user }

    context 'club owner' do
      let(:club_role) { build_stubbed :club_role, :admin, user: user }
      let(:club) do
        build_stubbed :club,
          owner: user,
          join_policy: join_policy,
          topic_policy: topic_policy,
          member_roles: [club_role]
      end

      it { is_expected.to be_able_to :see_club, club }

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user }
        it { is_expected.to_not be_able_to :new, club }
        it { is_expected.to_not be_able_to :create, club }
      end

      context 'day registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }
        it { is_expected.to_not be_able_to :new, club }
        it { is_expected.to_not be_able_to :create, club }
      end

      context 'not banned' do
        it { is_expected.to be_able_to :update, club }
        it { is_expected.to be_able_to :new, club }
        it { is_expected.to be_able_to :create, club }
        it { is_expected.to be_able_to :broadcast, club }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :user, :banned }
        it { is_expected.to_not be_able_to :update, club }
        it { is_expected.to_not be_able_to :new, club }
        it { is_expected.to_not be_able_to :create, club }
        it { is_expected.to_not be_able_to :broadcast, club }
      end

      describe 'invite' do
        context 'free' do
          let(:join_policy) { Types::Club::JoinPolicy[:free] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'member_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:member_invite] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'admin_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:admin_invite] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'owner_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:owner_invite] }
          it { is_expected.to be_able_to :invite, club }
        end
      end

      describe 'create_topic' do
        context 'members' do
          let(:topic_policy) { Types::Club::TopicPolicy[:members] }
          it { is_expected.to be_able_to :create_topic, club }
        end

        context 'admins' do
          let(:topic_policy) { Types::Club::TopicPolicy[:admins] }
          it { is_expected.to be_able_to :create_topic, club }
        end
      end

      context 'not club member' do
        let(:club) do
          build_stubbed :club,
            owner: user,
            join_policy: join_policy,
            topic_policy: topic_policy
        end

        describe 'join' do
          context 'free_join' do
            let(:join_policy) { Types::Club::JoinPolicy[:free] }
            it { is_expected.to be_able_to :join, club }
          end

          context 'member_invite' do
            let(:join_policy) { Types::Club::JoinPolicy[:member_invite] }
            it { is_expected.to be_able_to :join, club }
          end

          context 'admin_invite' do
            let(:join_policy) { Types::Club::JoinPolicy[:admin_invite] }
            it { is_expected.to be_able_to :join, club }
          end

          context 'owner_invite' do
            let(:join_policy) { Types::Club::JoinPolicy[:owner_invite] }
            it { is_expected.to be_able_to :join, club }
          end
        end
      end
    end

    context 'club administrator' do
      let(:club_role) { build_stubbed :club_role, :admin, user: user }
      let(:club) do
        build_stubbed :club,
          member_roles: [club_role],
          join_policy: join_policy,
          topic_policy: topic_policy
      end

      it { is_expected.to be_able_to :see_club, club }

      context 'not banned' do
        it { is_expected.to be_able_to :update, club }
        it { is_expected.to be_able_to :broadcast, club }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :user, :banned }
        it { is_expected.to_not be_able_to :update, club }
        it { is_expected.to_not be_able_to :broadcast, club }
      end

      describe 'invite' do
        context 'free' do
          let(:join_policy) { Types::Club::JoinPolicy[:free] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'member_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:member_invite] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'admin_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:admin_invite] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'owner_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:owner_invite] }
          it { is_expected.to_not be_able_to :invite, club }
        end
      end

      describe 'create_topic' do
        context 'members' do
          let(:topic_policy) { Types::Club::TopicPolicy[:members] }
          it { is_expected.to be_able_to :create_topic, club }
        end

        context 'admins' do
          let(:topic_policy) { Types::Club::TopicPolicy[:admins] }
          it { is_expected.to be_able_to :create_topic, club }
        end
      end
    end

    context 'club member' do
      let(:club) do
        build_stubbed :club,
          member_roles: [club_role].compact,
          join_policy: join_policy,
          topic_policy: topic_policy,
          image_upload_policy: image_upload_policy,
          display_images: display_images
      end
      let(:club_role) { build_stubbed :club_role, :member, user: user }
      let(:image_upload_policy) { Types::Club::ImageUploadPolicy[:members] }
      let(:display_images) { true }

      it { is_expected.to be_able_to :leave, club }
      it { is_expected.to_not be_able_to :broadcast, club }

      describe 'upload' do
        context 'members' do
          let(:image_upload_policy) { Types::Club::ImageUploadPolicy[:members] }

          context 'not member' do
            let(:club_role) { nil }
            it { is_expected.to_not be_able_to :upload_image, club }
          end

          context 'member' do
            it { is_expected.to be_able_to :upload_image, club }
          end
        end

        context 'admins' do
          let(:image_upload_policy) { Types::Club::ImageUploadPolicy[:admins] }

          context 'not member' do
            let(:club_role) { nil }
            it { is_expected.to_not be_able_to :upload_image, club }
          end

          context 'member' do
            it { is_expected.to_not be_able_to :upload_image, club }
          end

          context 'admin' do
            let(:club_role) { build_stubbed :club_role, :admin, user: user }
            it { is_expected.to be_able_to :upload_image, club }
          end
        end
      end

      describe 'create_topic' do
        context 'members' do
          let(:topic_policy) { Types::Club::TopicPolicy[:members] }
          it { is_expected.to be_able_to :create_topic, club }
        end

        context 'admins' do
          let(:topic_policy) { Types::Club::TopicPolicy[:admins] }
          it { is_expected.to_not be_able_to :create_topic, club }
        end
      end

      describe 'invite' do
        context 'free' do
          let(:join_policy) { Types::Club::JoinPolicy[:free] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'member_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:member_invite] }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'admin_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:admin_invite] }
          it { is_expected.to_not be_able_to :invite, club }
        end

        context 'owner_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:owner_invite] }
          it { is_expected.to_not be_able_to :invite, club }
        end
      end
    end

    context 'guest' do
      let(:user) { nil }
      it { is_expected.to be_able_to :see_club, club }
      it { is_expected.to_not be_able_to :new, club }
      it { is_expected.to_not be_able_to :update, club }
      it { is_expected.to_not be_able_to :invite, club }
      it { is_expected.to_not be_able_to :upload_image, club }
      it { is_expected.to_not be_able_to :create_topic, club }
      it { is_expected.to_not be_able_to :broadcast, club }
    end

    context 'user' do
      it { is_expected.to be_able_to :see_club, club }
      it { is_expected.to_not be_able_to :new, club }
      it { is_expected.to_not be_able_to :update, club }
      it { is_expected.to_not be_able_to :invite, club }
      it { is_expected.to_not be_able_to :broadcast, club }
      it { is_expected.to_not be_able_to :create_topic, club }

      context 'banned in club' do
        let(:club) do
          build_stubbed :club,
            join_policy: join_policy,
            topic_policy: topic_policy,
            bans: [club_ban]
        end
        let(:club_ban) { build_stubbed :club_ban, user: user }
        it { is_expected.to_not be_able_to :join, club }
      end

      context 'not banned in club' do
        context 'free' do
          let(:join_policy) { Types::Club::JoinPolicy[:free] }
          it { is_expected.to be_able_to :join, club }
        end

        context 'admin_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:admin_invite] }
          it { is_expected.to_not be_able_to :join, club }
        end

        context 'owner_invite' do
          let(:join_policy) { Types::Club::JoinPolicy[:owner_invite] }
          it { is_expected.to_not be_able_to :join, club }
        end
      end
    end
  end

  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'instance methods' do
      let(:model) { build_stubbed :club }

      describe '#generate_topics' do
        let(:topics) { model.topics }
        before { model.generate_topics model.locale }

        it do
          expect(topics).to have(1).item
          expect(topics.first.locale).to eq model.locale
        end
      end

      describe '#topic' do
        let(:topic) { model.topic locale }
        before { model.generate_topics model.locale }

        context 'locale from model' do
          let(:locale) { model.locale }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale.to_s
          end
        end

        context 'locale not from model' do
          let(:locale) { (Shikimori::DOMAIN_LOCALES - [model.locale.to_sym]).sample }
          it { expect(topic).to be_nil }
        end
      end

      describe '#maybe_topic' do
        let(:topic) { model.maybe_topic locale }
        before { model.generate_topics model.locale }

        context 'locale from model' do
          let(:locale) { model.locale }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale.to_s
          end
        end

        context 'locale not from model' do
          let(:locale) { (Shikimori::DOMAIN_LOCALES - [model.locale.to_sym]).sample }
          it do
            expect(topic).to be_present
            expect(topic).to be_instance_of NoTopic
            expect(topic.linked).to eq model
          end
        end
      end

      describe '#topic_user' do
        it { expect(model.topic_user).to eq model.owner }
      end
    end
  end

  it_behaves_like :antispam_concern, :club
end
