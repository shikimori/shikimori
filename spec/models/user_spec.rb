require 'cancan/matchers'

describe User do
  describe 'relations' do
    it { is_expected.to have_one :preferences }

    it { is_expected.to have_many :versions }

    it { is_expected.to have_many :anime_rates }
    it { is_expected.to have_many :manga_rates }

    it { is_expected.to have_many :history }

    it { is_expected.to have_many :friend_links }
    it { is_expected.to have_many :friends }

    it { is_expected.to have_many :favourites }
    it { is_expected.to have_many :fav_animes }
    it { is_expected.to have_many :fav_mangas }
    it { is_expected.to have_many :fav_people }
    it { is_expected.to have_many :fav_seyu }
    it { is_expected.to have_many :fav_producers }
    it { is_expected.to have_many :fav_mangakas }
    it { is_expected.to have_many :fav_characters }

    it { is_expected.to have_many :abuse_requests }
    it { is_expected.to have_many :messages }
    it { is_expected.to have_many :comments }

    it { is_expected.to have_many :reviews }
    it { is_expected.to have_many :votes }

    it { is_expected.to have_many :ignores }
    it { is_expected.to have_many :ignored_users }

    it { is_expected.to have_many :group_roles }
    it { is_expected.to have_many :groups }

    it { is_expected.to have_many :entry_views }

    it { is_expected.to have_many :contest_user_votes }

    it { is_expected.to have_many :nickname_changes }
    it { is_expected.to have_many :recommendation_ignores }

    it { is_expected.to have_many :bans }
    it { is_expected.to have_many :group_bans }

    it { is_expected.to have_many :devices }

    it { is_expected.to have_many :user_tokens }
    it { is_expected.to have_many :user_images }

    it { is_expected.to have_many :anime_video_reports }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:language).in(:russian, :english) }
  end

  let(:user) { create :user }
  let(:user2) { create :user }
  let(:topic) { create :topic }

  describe 'hooks' do
    it { expect(user.preferences).to be_persisted }

    #it 'creates registration history entry' do
      #user.history.is_expected.to have(1).item
      #user.history.first.action.is_expected.to eq UserHistoryAction::Registration
    #end

    describe '#log_nickname_change' do
      let(:user) { create :user }
      after { user.update nickname: 'test' }
      it { expect(UserNicknameChange).to receive(:create).with(user: user, value: user.nickname) }
    end
  end

  describe 'instance methods' do
    describe '#nickname=' do
      let(:user) { create :user, nickname: '#[test]%&?+@' }
      it { expect(user.nickname).to eq 'test' }
    end

    describe '#can_post' do
      before { user.read_only_at = read_only_at }
      subject { user.can_post? }

      context 'no ban' do
        let(:read_only_at) { nil }
        it { is_expected.to be_truthy }
      end

      context 'expired ban' do
        let(:read_only_at) { Time.zone.now - 1.second }
        it { is_expected.to be_truthy }
      end

      context 'valid ban' do
        let(:read_only_at) { Time.zone.now + 1.seconds }
        it { is_expected.to be_falsy }
      end
    end

    describe '#ignores?' do
      it do
        user.ignored_users << user2
        expect(user.ignores?(user2)).to be_truthy
      end

      it do
        expect(user.ignores?(user2)).to be_falsy
      end
    end

    context 'when profile is commented' do
      it "then new MessageType::ProfileCommented notification is created" do
        user1 = create :user
        user2 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user2
        }.to change(Message, :count).by 1
        message = Message.last
        expect(message.kind).to eq(MessageType::ProfileCommented)
        expect(message.from_id).to eq user1.id
        expect(message.to_id).to eq user2.id
      end

      it "two times, then only one MessageType::ProfileCommented notification is created" do
        user1 = create :user
        user2 = create :user
        user3 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user2
          create :comment, :with_creation_callbacks, user: user3, commentable: user2
        }.to change(Message, :count).by 1
        message = Message.last
        expect(message.kind).to eq(MessageType::ProfileCommented)
        expect(message.from_id).to eq user1.id
        expect(message.to_id).to eq user2.id
      end

      it "by its owner, then no MessageType::ProfileCommented notification is created" do
        user1 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user1
        }.to_not change Message, :count
      end

      it "and user read it, and then commented again, then second MessageType::ProfileCommented notification is created" do
        user1 = create :user
        user2 = create :user
        user3 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user2
          Message.last.update_attribute(:read, true)
          create :comment, :with_creation_callbacks, user: user3, commentable: user2
        }.to change(Message, :count).by 2
        message = Message.last
        expect(message.kind).to eq MessageType::ProfileCommented
        expect(message.from_id).to eq user3.id
        expect(message.to_id).to eq user2.id
      end
    end

    it '#prolongate_ban' do
      read_only_at = DateTime.now + 5.hours
      ip = '127.0.0.1'

      user.read_only_at = read_only_at
      user.current_sign_in_ip = ip
      user.save

      user2.current_sign_in_ip = ip
      user2.prolongate_ban

      expect(user2.read_only_at.to_i).to eq read_only_at.to_i
    end

    describe '#banned?' do
      let(:read_only_at) { nil }
      subject { create(:user, read_only_at: read_only_at).banned? }

      it { is_expected.to be_falsy }

      describe 'true' do
        let(:read_only_at) { DateTime.now + 1.hour }
        it { is_expected.to be_truthy }
      end

      describe 'false' do
        let(:read_only_at) { DateTime.now - 1.second }
        it { is_expected.to be_falsy }
      end
    end

    describe '#friended?' do
      subject { user.friended? user_2 }
      let(:user_2) { build_stubbed :user }

      context 'friended' do
        let(:user) { build_stubbed :user, friend_links: [build_stubbed(:friend_link, dst: user_2)] }
        it { is_expected.to be true }
      end

      context 'not friended' do
        it { is_expected.to be false }
      end
    end

    describe '#forever_banned?' do
      let(:user) { build :user, read_only_at: read_only_at }

      context 'banned not long ago' do
        let(:read_only_at) { 11.month.from_now }
        it { expect(user.forever_banned?).to be false }
      end

      context 'not banned' do
        let(:read_only_at) { nil }
        it { expect(user.forever_banned?).to be false }
      end

      context 'banned long ago' do
        let(:read_only_at) { 13.month.from_now }
        it { expect(user.forever_banned?).to be true }
      end
    end

    describe '#day_registered?' do
      let(:user) { build :user, created_at: created_at }

      context 'created_at not day ago' do
        let(:created_at) { 23.hours.ago }
        it { expect(user.day_registered?).to be false }
      end

      context 'created_at day ago' do
        let(:created_at) { 25.hours.ago }
        it { expect(user.day_registered?).to be true }
      end
    end
  end

  describe 'permissions' do
    let(:preferences) { build_stubbed(:user_preferences, list_privacy: list_privacy) }
    let(:profile) { build_stubbed :user, :user, preferences: preferences }
    let(:user) { build_stubbed :user, :user }
    let(:friend_link) { build_stubbed :friend_link, dst: user }
    subject { Ability.new user }

    describe 'access_list' do
      context 'public list_privacy' do
        let(:list_privacy) { :public }

        context 'owner' do
          let(:user) { profile }
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'user' do
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { is_expected.to be_able_to :access_list, profile }
        end
      end

      context 'users list_privacy' do
        let(:list_privacy) { :users }

        context 'owner' do
          let(:user) { profile }
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'user' do
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { is_expected.to_not be_able_to :access_list, profile }
        end
      end

      context 'friends list_privacy' do
        let(:list_privacy) { :friends }

        context 'owner' do
          let(:user) { profile }
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'user' do
          it { is_expected.to_not be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { is_expected.to_not be_able_to :access_list, profile }
        end
      end

      context 'owner list_privacy' do
        let(:list_privacy) { :owner }

        context 'owner' do
          let(:user) { profile }
          it { is_expected.to be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { is_expected.to_not be_able_to :access_list, profile }
        end

        context 'user' do
          it { is_expected.to_not be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { is_expected.to_not be_able_to :access_list, profile }
        end
      end
    end

    describe 'access_messages' do
      let(:profile) { build_stubbed :user, :user }

      context 'owner' do
        let(:user) { profile }
        it { is_expected.to be_able_to :access_messages, profile }
      end

      context 'user' do
        it { is_expected.to_not be_able_to :access_messages, profile }
      end

      context 'guest' do
        let(:user) { nil }
        it { is_expected.to_not be_able_to :access_messages, profile }
      end
    end

    describe 'edit & update' do
      let(:profile) { build_stubbed :user, :user }

      context 'own profile' do
        let(:user) { profile }
        it { is_expected.to be_able_to :edit, profile }
        it { is_expected.to be_able_to :update, profile }
      end

      context 'admin' do
        let(:user) { build_stubbed :user, id: User::Admins.first }
        it { is_expected.to be_able_to :edit, profile }
        it { is_expected.to be_able_to :update, profile }
      end

      context 'user' do
        it { is_expected.to_not be_able_to :edit, profile }
        it { is_expected.to_not be_able_to :update, profile }
      end

      context 'guest' do
        it { is_expected.to_not be_able_to :edit, profile }
        it { is_expected.to_not be_able_to :update, profile }
      end
    end
  end
end
