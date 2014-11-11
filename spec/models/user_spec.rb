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
    it { user.preferences.should be_persisted }

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
        it { should be_true }
      end

      context 'expired ban' do
        let(:read_only_at) { Time.zone.now - 1.second }
        it { should be_true }
      end

      context 'valid ban' do
        let(:read_only_at) { Time.zone.now + 1.seconds }
        it { should be_false }
      end
    end

    it '#subscribed?' do
      create :subscription, user: user, target_id: topic.id, target_type: topic.class.name
      user.subscribed?(topic).should be_true
    end

    describe '#ignores?' do
      it do
        user.ignored_users << user2
        user.ignores?(user2).should be_true
      end

      it do
        user.ignores?(user2).should be_false
      end
    end

    describe '#subscribe' do
      it 'works' do
        topic

        expect {
          user.subscribe(topic)
        }.to change(Subscription, :count).by 1

        user.subscribed?(topic).should be_true
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

      User.find(user.id).subscribed?(topic).should be_false
    end

    context 'when profile is commented' do
      it "then new MessageType::ProfileCommented notification is created" do
        user1 = create :user
        user2 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user2
        }.to change(Message, :count).by 1
        message = Message.last
        message.kind.should == MessageType::ProfileCommented
        message.from_id.should eq user1.id
        message.to_id.should eq user2.id
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
        message.kind.should == MessageType::ProfileCommented
        message.from_id.should eq user1.id
        message.to_id.should eq user2.id
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
        message.kind.should eq MessageType::ProfileCommented
        message.from_id.should eq user3.id
        message.to_id.should eq user2.id
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

      user2.read_only_at.to_i.should eq read_only_at.to_i
    end

    describe '#banned?' do
      let(:read_only_at) { nil }
      subject { create(:user, read_only_at: read_only_at).banned? }

      it { should be_false }

      describe 'true' do
        let(:read_only_at) { DateTime.now + 1.hour }
        it { should be_true }
      end

      describe 'false' do
        let(:read_only_at) { DateTime.now - 1.second }
        it { should be_false }
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
  end

  describe 'permissions' do
    let(:preferences) { build_stubbed(:user_preferences, profile_privacy: profile_privacy) }
    let(:profile) { build_stubbed :user, preferences: preferences }
    let(:user) { build_stubbed :user }
    let(:friend_link) { build_stubbed :friend_link, dst: user }
    subject { Ability.new user }

    describe 'see_list' do
      context 'public profile_privacy' do
        let(:profile_privacy) { :public }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :see_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, friend_links: [friend_link], preferences: preferences }
          it { should be_able_to :see_list, profile }
        end

        context 'user' do
          it { should be_able_to :see_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should be_able_to :see_list, profile }
        end
      end

      context 'users profile_privacy' do
        let(:profile_privacy) { :users }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :see_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, friend_links: [friend_link], preferences: preferences }
          it { should be_able_to :see_list, profile }
        end

        context 'user' do
          it { should be_able_to :see_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should_not be_able_to :see_list, profile }
        end
      end

      context 'friends profile_privacy' do
        let(:profile_privacy) { :friends }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :see_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, friend_links: [friend_link], preferences: preferences }
          it { should be_able_to :see_list, profile }
        end

        context 'user' do
          it { should_not be_able_to :see_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should_not be_able_to :see_list, profile }
        end
      end

      context 'owner profile_privacy' do
        let(:profile_privacy) { :owner }

        context 'owner' do
          let(:user) { profile }
          it { should be_able_to :see_list, profile }
        end

        context 'friend' do
          let(:profile) { build_stubbed :user, friend_links: [friend_link], preferences: preferences }
          it { should_not be_able_to :see_list, profile }
        end

        context 'user' do
          it { should_not be_able_to :see_list, profile }
        end

        context 'guest' do
          let(:user) { nil }
          it { should_not be_able_to :see_list, profile }
        end
      end
    end

    describe 'edit & update' do
      let(:profile) { build_stubbed :user }

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
