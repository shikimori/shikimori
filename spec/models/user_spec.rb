require 'cancan/matchers'

describe User do
  describe 'relations' do
    it { should have_one :preferences }

    it { should have_many :user_changes }

    it { should have_many :anime_rates }
    it { should have_many :manga_rates }

    it { should have_many :history }
    it { should have_many :subscriptions }

    it { should have_many :friend_links }
    it { should have_many :friends }

    it { should have_many :favourites }
    it { should have_many :fav_animes }
    it { should have_many :fav_mangas }
    it { should have_many :fav_people }
    it { should have_many :fav_seyu }
    it { should have_many :fav_producers }
    it { should have_many :fav_mangakas }
    it { should have_many :fav_characters }

    it { should have_many :abuse_requests }
    it { should have_many :messages }
    it { should have_many :comments }

    it { should have_many :reviews }
    it { should have_many :votes }

    it { should have_many :ignores }
    it { should have_many :ignored_users }

    it { should have_many :group_roles }
    it { should have_many :groups }

    it { should have_many :entry_views }

    it { should have_many :contest_user_votes }

    it { should have_many :nickname_changes }
    it { should have_many :recommendation_ignores }

    it { should have_many :bans }
    it { should have_many :group_bans }

    it { should have_many :devices }
  end

  let(:user) { create :user }
  let(:user2) { create :user }
  let(:topic) { create :topic }

  describe 'hooks' do
    it { expect(user.preferences).to be_persisted }

    #it 'creates registration history entry' do
      #user.history.should have(1).item
      #user.history.first.action.should eq UserHistoryAction::Registration
    #end

    describe '#fix_nickname' do
      let(:user) { create :user, nickname: '#[test]%&?+' }
      it { expect(user.nickname).to eq 'test' }
    end

    describe '#log_nickname_change' do
      let(:user) { create :user }
      after { user.update nickname: 'test' }
      it { expect(UserNicknameChange).to receive(:create).with(user: user, value: user.nickname) }
    end
  end

  describe 'instance methods' do
    describe '#can_post' do
      before { user.read_only_at = read_only_at }
      subject { user.can_post? }

      context 'no ban' do
        let(:read_only_at) { nil }
        it { should be_truthy }
      end

      context 'expired ban' do
        let(:read_only_at) { Time.zone.now - 1.second }
        it { should be_truthy }
      end

      context 'valid ban' do
        let(:read_only_at) { Time.zone.now + 1.seconds }
        it { should be_falsy }
      end
    end

    it '#subscribed?' do
      create :subscription, user: user, target_id: topic.id, target_type: topic.class.name
      expect(user.subscribed?(topic)).to be_truthy
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

    describe '#subscribe' do
      it 'works' do
        topic

        expect {
          user.subscribe(topic)
        }.to change(Subscription, :count).by 1

        expect(user.subscribed?(topic)).to be_truthy
      end

      it 'only_once' do
        topic

        expect {
          user.subscribe(topic)
          user.subscribe(topic)
        }.to change(Subscription, :count).by 1
      end
    end

    it '#usubscribe' do
      user.subscribe(topic)
      expect {
        user.unsubscribe(topic)
      }.to change(Subscription, :count).by -1

      expect(User.find(user.id).subscribed?(topic)).to be_falsy
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

      it { should be_falsy }

      describe 'true' do
        let(:read_only_at) { DateTime.now + 1.hour }
        it { should be_truthy }
      end

      describe 'false' do
        let(:read_only_at) { DateTime.now - 1.second }
        it { should be_falsy }
      end
    end

    describe '#friended?' do
      subject { user.friended? user_2 }
      let(:user_2) { build_stubbed :user }

      context 'friended' do
        let(:user) { build_stubbed :user, friend_links: [build_stubbed(:friend_link, dst: user_2)] }
        it { should be true }
      end

      context 'not friended' do
        it { should be false }
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
    let(:preferences) { build_stubbed(:user_preferences, profile_privacy: profile_privacy) }
    let(:profile) { build_stubbed :user, :user, preferences: preferences }
    let(:user) { build_stubbed :user, :user }
    let(:friend_link) { build_stubbed :friend_link, dst: user }
    subject { Ability.new user }

    describe 'access_list' do
      context 'public profile_privacy' do
        let(:profile_privacy) { :public }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { should be_able_to :access_list, profile }
        end

        context 'user' do
          it { should be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should be_able_to :access_list, profile }
        end
      end

      context 'users profile_privacy' do
        let(:profile_privacy) { :users }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { should be_able_to :access_list, profile }
        end

        context 'user' do
          it { should be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should_not be_able_to :access_list, profile }
        end
      end

      context 'friends profile_privacy' do
        let(:profile_privacy) { :friends }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { should be_able_to :access_list, profile }
        end

        context 'user' do
          it { should_not be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should_not be_able_to :access_list, profile }
        end
      end

      context 'owner profile_privacy' do
        let(:profile_privacy) { :owner }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :access_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, :user, friend_links: [friend_link], preferences: preferences }
          it { should_not be_able_to :access_list, profile }
        end

        context 'user' do
          it { should_not be_able_to :access_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should_not be_able_to :access_list, profile }
        end
      end
    end

    describe 'access_messages' do
      let(:profile) { build_stubbed :user, :user }

      context 'owner' do
        let(:user) { profile }
        it { should be_able_to :access_messages, profile }
      end

      context 'user' do
        it { should_not be_able_to :access_messages, profile }
      end

      context 'guest' do
        let(:user) { nil }
        it { should_not be_able_to :access_messages, profile }
      end
    end

    describe 'edit & update' do
      let(:profile) { build_stubbed :user, :user }

      context 'own profile' do
        let(:user) { profile }
        it { should be_able_to :edit, profile }
        it { should be_able_to :update, profile }
      end

      context 'admin' do
        let(:user) { build_stubbed :user, id: User::Admins.first }
        it { should be_able_to :edit, profile }
        it { should be_able_to :update, profile }
      end

      context 'user' do
        it { should_not be_able_to :edit, profile }
        it { should_not be_able_to :update, profile }
      end

      context 'guest' do
        it { should_not be_able_to :edit, profile }
        it { should_not be_able_to :update, profile }
      end
    end
  end
end
