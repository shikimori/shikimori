# frozen_string_literal: true

describe Club do
  describe 'relations' do
    it { is_expected.to have_many(:member_roles).dependent(:destroy) }
    it { is_expected.to have_many :members }

    # it { is_expected.to have_many :moderator_roles }
    # it { is_expected.to have_many :moderators }

    it { is_expected.to have_many :admin_roles }
    it { is_expected.to have_many :admins }

    it { is_expected.to have_many(:links).dependent(:destroy) }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :characters }

    it { is_expected.to have_many(:images).dependent(:destroy) }

    it { is_expected.to belong_to :owner }

    it { is_expected.to have_many(:invites).dependent(:destroy) }
    it { is_expected.to have_many(:bans).dependent(:destroy) }
    it { is_expected.to have_many :banned_users }

    it { is_expected.to belong_to :style }
    it { is_expected.to have_many(:styles).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :owner }
    it { is_expected.to have_attached_file :logo }
    it { is_expected.to validate_presence_of :locale }
  end

  describe 'callbacks' do
    describe '#join_owner' do
      let(:club) { create :club, :with_owner_join }
      it { expect(club.joined? club.owner).to eq true }
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
  end

  describe 'instance methods' do
    let(:user) { create :user }

    describe '#nickname=' do
      let(:club) { build :club, name: name }
      let(:name) { '#[test]%&?+@' }

      it { expect(club.name).to eq FixName.call(name, false) }
    end

    describe '#ban' do
      let(:user) { create :user }
      let(:club) { create :club }
      before { club.ban user }

      it { expect(club.banned? user).to be true }
    end

    describe '#join' do
      let(:user) { create :user }
      let(:club) { create :club }
      before { club.join user }

      it { expect(club.reload.club_roles_count).to eq 1 }
      it { expect(club.joined? user).to be true }

      context 'user' do
        it { expect(club.admin? user).to be_falsy }
      end

      context 'club_owner' do
        let(:club) { create :club, owner: user }
        it { expect(club.admin? user).to be_truthy }
      end

      describe '#leave' do
        before { club.reload.leave user }

        it { expect(club.joined? user).to be false }
        it { expect(club.reload.club_roles_count).to be_zero }
      end
    end

    describe '#member_role' do
      let(:user) { build_stubbed :user }
      let(:club) { build_stubbed :club, member_roles: [club_role] }
      let(:club_role) { build_stubbed :club_role, user: user }
      subject { club.member_role user }

      it { is_expected.to eq club_role }
    end

    describe '#joined?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.joined? user }

      context 'owner' do
        let(:club) { build_stubbed :club, owner: user }
        it { is_expected.to be false }
      end

      context 'admin' do
        let(:club) { build_stubbed :club, member_roles: [build_stubbed(:club_role, :member, user: user)] }
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
        let(:club) { build_stubbed :club, member_roles: [build_stubbed(:club_role, :admin, user: user)] }
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
        let(:club) { build_stubbed :club, invites: [build_stubbed(:club_invite, dst: user)] }
        it { is_expected.to be true }
      end

      context 'not invited' do
        it { is_expected.to be false }
      end
    end
  end

  describe 'permissions' do
    let(:club) { build_stubbed :club, join_policy: join_policy }
    let(:user) { build_stubbed :user, :user, :day_registered }
    let(:join_policy) { :free_join }

    subject { Ability.new user }

    context 'club owner' do
      let(:club_role) { build_stubbed :club_role, :admin, user: user }
      let(:club) { build_stubbed :club, owner: user, join_policy: join_policy, member_roles: [club_role] }

      it { is_expected.to be_able_to :see_club, club }

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user }
        it { is_expected.to_not be_able_to :new, club }
        it { is_expected.to_not be_able_to :create, club }
      end

      context 'not banned' do
        it { is_expected.to be_able_to :update, club }
        it { is_expected.to be_able_to :upload, club }
        it { is_expected.to be_able_to :new, club }
        it { is_expected.to be_able_to :create, club }
        it { is_expected.to be_able_to :broadcast, club }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :user, :banned }
        it { is_expected.to_not be_able_to :update, club }
        it { is_expected.to_not be_able_to :upload, club }
        it { is_expected.to_not be_able_to :new, club }
        it { is_expected.to_not be_able_to :create, club }
        it { is_expected.to_not be_able_to :broadcast, club }
      end

      describe 'invite' do
        context 'free_join' do
          let(:join_policy) { :free_join }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'admin_invite_join' do
          let(:join_policy) { :admin_invite_join }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'owner_invite_join' do
          let(:join_policy) { :owner_invite_join }
          it { is_expected.to be_able_to :invite, club }
        end
      end

      context 'not club member' do
        let(:club) { build_stubbed :club, owner: user, join_policy: join_policy }

        describe 'join' do
          context 'free_join' do
            let(:join_policy) { :free_join }
            it { is_expected.to be_able_to :join, club }
          end

          context 'admin_invite_join' do
            let(:join_policy) { :admin_invite_join }
            it { is_expected.to be_able_to :join, club }
          end

          context 'owner_invite_join' do
            let(:join_policy) { :owner_invite_join }
            it { is_expected.to be_able_to :join, club }
          end
        end
      end
    end

    context 'club administrator' do
      let(:club_role) { build_stubbed :club_role, :admin, user: user }
      let(:club) { build_stubbed :club, member_roles: [club_role], join_policy: join_policy }

      it { is_expected.to be_able_to :see_club, club }

      context 'not banned' do
        it { is_expected.to be_able_to :update, club }
        it { is_expected.to be_able_to :upload, club }
        it { is_expected.to be_able_to :broadcast, club }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :user, :banned }
        it { is_expected.to_not be_able_to :update, club }
        it { is_expected.to_not be_able_to :upload, club }
        it { is_expected.to_not be_able_to :broadcast, club }
      end

      describe 'invite' do
        context 'free_join' do
          let(:join_policy) { :free_join }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'admin_invite_join' do
          let(:join_policy) { :admin_invite_join }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'owner_invite_join' do
          let(:join_policy) { :owner_invite_join }
          it { is_expected.to_not be_able_to :invite, club }
        end
      end
    end

    context 'club member' do
      let(:club_role) { build_stubbed :club_role, user: user }
      let(:club) { build_stubbed :club, member_roles: [club_role], join_policy: join_policy, upload_policy: upload_policy, display_images: display_images }
      let(:upload_policy) { ClubUploadPolicy::ByMembers }
      let(:display_images) { true }

      it { is_expected.to be_able_to :leave, club }
      it { is_expected.to_not be_able_to :broadcast, club }

      describe 'upload' do
        context 'by_staff' do
          let(:upload_policy) { ClubUploadPolicy::ByStaff }
          it { is_expected.to_not be_able_to :upload, club }
        end

        context 'by_members' do
          let(:upload_policy) { ClubUploadPolicy::ByMembers }

          context 'display_images' do
            it { is_expected.to be_able_to :upload, club }
          end

          context 'do not display_images' do
            let(:display_images) { false }
            it { is_expected.to_not be_able_to :upload, club }
          end
        end
      end

      describe 'invite' do
        context 'free_join' do
          let(:join_policy) { :free_join }
          it { is_expected.to be_able_to :invite, club }
        end

        context 'admin_invite_join' do
          let(:join_policy) { :admin_invite_join }
          it { is_expected.to_not be_able_to :invite, club }
        end

        context 'owner_invite_join' do
          let(:join_policy) { :owner_invite_join }
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
      it { is_expected.to_not be_able_to :upload, club }
      it { is_expected.to_not be_able_to :broadcast, club }
    end

    context 'user' do
      it { is_expected.to be_able_to :see_club, club }
      it { is_expected.to_not be_able_to :new, club }
      it { is_expected.to_not be_able_to :update, club }
      it { is_expected.to_not be_able_to :invite, club }
      it { is_expected.to_not be_able_to :upload, club }
      it { is_expected.to_not be_able_to :broadcast, club }

      context 'free_join' do
        let(:join_policy) { :free_join }
        it { is_expected.to be_able_to :join, club }
      end

      context 'admin_invite_join' do
        let(:join_policy) { :admin_invite_join }
        it { is_expected.to_not be_able_to :join, club }
      end

      context 'owner_invite_join' do
        let(:join_policy) { :owner_invite_join }
        it { is_expected.to_not be_able_to :join, club }
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
          let(:locale) { (Site::DOMAIN_LOCALES - [model.locale.to_sym]).sample }
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
          let(:locale) { (Site::DOMAIN_LOCALES - [model.locale.to_sym]).sample }
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
end
