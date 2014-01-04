require 'spec_helper'

describe User do
  context :relations do
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
  end

  let(:user) { create :user }
  let(:user2) { create :user }
  let(:topic) { create :topic }

  context :hooks do
    it 'creates preferences' do
      user.preferences.should be_persisted
    end

    #it 'creates registration history entry' do
      #user.history.should have(1).item
      #user.history.first.action.should eq UserHistoryAction::Registration
    #end

    it 'fixes nickname' do
      create(:user, nickname: '#[test]%&?+').nickname.should eq 'test'
    end

    describe 'nickname change' do
      before { @old_nickname = user.nickname }

      context 'less than one day after registration' do
        before do
          user.stub_chain(:comments, :count).and_return 11
          user.created_at = 23.hours.ago
          user.update_attributes! nickname: 'zxc'
        end

        it { user.nickname_changes.should have(0).items }
      end

      context 'one or more days after registration' do
        before do
          user.created_at = 1.day.ago
          user.stub_chain(:comments, :count).and_return 11
        end

        describe 'too few comments' do
          before do
            user.stub_chain(:comments, :count).and_return 9
            user.update_attributes! nickname: 'zxc'
          end

          it { user.nickname_changes.should have(0).items }
        end

        describe 'nickname_change creation' do
          before { user.update_attributes! nickname: 'zxc' }

          it { user.nickname_changes.should have(1).item }
          it { user.nickname_changes.first.value.should eq @old_nickname }

          it 'logs only uniq changes' do
            user.update_attributes! nickname: @old_nickname
            user.update_attributes! nickname: 'zxc'

            user.nickname_changes.should have(2).items
          end

          context 'default nickname' do
            let (:user) { create :user, nickname: 'Новый пользователь2', created_at: 1.year.ago }
            before { user.update_attributes! nickname: 'zxc' }

            it { user.nickname_changes.should have(0).items }
          end
        end

        describe 'friends notification' do
          let (:user3) { create :user }
          let (:user4) { create :user }

          before do
            user2.friends << user
            user3.friends << user
            user4.update_attribute :notifications, User::DEFAULT_NOTIFICATIONS - User::NICKNAME_CHANGE_NOTIFICATIONS
            user4.friends << user
          end

          it 'creates messages for each friend' do
            expect {
              user.update_attributes! nickname: 'zxc'
            }.to change(Message, :count).by 2
          end

          it 'creates correct messages' do
            user.update_attributes! nickname: 'zxc'
            message = Message.last

            message.kind.should eq MessageType::NicknameChanged
            message.dst_id.should eq user3.id
            message.body.should include(@old_nickname)
            message.body.should include(user.nickname)
          end
        end
      end
    end
  end

  context :instance_methods do
    describe :can_post do
      it true do
        user.can_post?.should be_true
      end

      it false do
        user.read_only_at = DateTime.now + 1.day

        user.can_post?.should be_false
      end
    end

    it :subscribed? do
      create :subscription, user: user, target_id: topic.id, target_type: topic.class.name

      user.subscribed?(topic).should be_true
    end

    describe :ignores? do
      it do
        user.ignored_users << user2
        user.ignores?(user2).should be_true
      end

      it do
        user.ignores?(user2).should be_false
      end
    end

    describe :subscribe do
      it :works do
        topic

        expect {
          user.subscribe(topic)
        }.to change(Subscription, :count).by 1

        user.subscribed?(topic).should be_true
      end

      it :only_once do
        topic

        expect {
          user.subscribe(topic)
          user.subscribe(topic)
        }.to change(Subscription, :count).by 1
      end
    end

    it :usubscribe do
      user.subscribe(topic)
      expect {
        user.unsubscribe(topic)
      }.to change(Subscription, :count).by -1

      User.find(user.id).subscribed?(topic).should be_false
    end

    describe "when profile is commented" do
      it "then new MessageType::ProfileCommented notification is created" do
        user1 = create :user
        user2 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user2
        }.to change(Message, :count).by(1)
        message = Message.last
        message.kind.should == MessageType::ProfileCommented
        message.src_id.should == user1.id
        message.src_type.should == User.name
        message.dst_id.should == user2.id
        message.dst_type.should == User.name
      end

      it "two times, then only one MessageType::ProfileCommented notification is created" do
        user1 = create :user
        user2 = create :user
        user3 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user2
          create :comment, :with_creation_callbacks, user: user3, commentable: user2
        }.to change(Message, :count).by(1)
        message = Message.last
        message.kind.should == MessageType::ProfileCommented
        message.src_id.should == user1.id
        message.src_type.should == User.name
        message.dst_id.should == user2.id
        message.dst_type.should == User.name
      end

      it "by its owner, then no MessageType::ProfileCommented notification is created" do
        user1 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user1
        }.to_not change(Message, :count)
      end

      it "and user read it, and then commented again, then second MessageType::ProfileCommented notification is created" do
        user1 = create :user
        user2 = create :user
        user3 = create :user
        expect {
          create :comment, :with_creation_callbacks, user: user1, commentable: user2
          Message.last.update_attribute(:read, true)
          create :comment, :with_creation_callbacks, user: user3, commentable: user2
        }.to change(Message, :count).by(2)
        message = Message.last
        message.kind.should == MessageType::ProfileCommented
        message.src_id.should == user3.id
        message.src_type.should == User.name
        message.dst_id.should == user2.id
        message.dst_type.should == User.name
      end
    end

    it :prolongate_ban do
      read_only_at = DateTime.now + 5.hours
      ip = '127.0.0.1'

      user.read_only_at = read_only_at
      user.current_sign_in_ip = ip
      user.save

      user2.current_sign_in_ip = ip
      user2.prolongate_ban

      user2.read_only_at.to_i.should eq read_only_at.to_i
    end

    describe :banned? do
      let(:read_only_at) { nil }
      subject { create(:user, read_only_at: read_only_at).banned? }

      it { should be_false }

      describe true do
        let(:read_only_at) { DateTime.now + 1.hour }
        it { should be_true }
      end

      describe false do
        let(:read_only_at) { DateTime.now - 1.second }
        it { should be_false }
      end
    end
  end
end
