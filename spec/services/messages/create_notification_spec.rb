describe Messages::CreateNotification do
  let(:service) { described_class.new target }

  before { allow(BotsService).to receive(:get_poster).and_return bot }
  let(:bot) { seed :user }

  describe '#user_registered' do
    let(:target) { user_2 }
    let!(:sender) { user }
    it do
      expect { service.user_registered }.to change(target.messages, :count).by 1
    end
  end

  describe '#moderatable_banned' do
    let(:target) { create :critique, :with_topics, user: author, approver: approver }
    let(:author) { seed :user }
    let(:approver) { create :user }

    subject(:message) { service.moderatable_banned reason }

    context 'with reason' do
      let(:reason) { 'test' }

      it do
        expect { subject }.to change(Message, :count).by 1
        is_expected.to be_persisted
        is_expected.to have_attributes(
          from: approver,
          to: author,
          kind: MessageType::NOTIFICATION,
          linked: target,
          body: <<-BODY.squish.strip
            Твоя [entry=#{target.topic.id}]рецензия[/entry]
            перенесена в оффтоп по причине
            [quote=#{approver.nickname}]#{reason}[/quote]
          BODY
        )
      end
    end

    context 'without reason' do
      let(:reason) { '' }

      it do
        expect { subject }.to change(Message, :count).by 1
        is_expected.to be_persisted
        is_expected.to have_attributes(
          from: approver,
          to: author,
          kind: MessageType::NOTIFICATION,
          linked: target,
          body: <<-BODY.squish.strip
            Твоя [entry=#{target.topic.id}]рецензия[/entry]
            перенесена в оффтоп.
          BODY
        )
      end
    end
  end

  describe '#nickname_changed' do
    let(:target) { seed :user }
    let(:friend) { create :user, notification_settings: notification_settings }
    let(:old_nickname) { 'old_nick' }
    let(:new_nickname) { 'new_nick' }

    subject(:message) { service.nickname_changed friend, old_nickname, new_nickname }

    context 'disabled_notifications' do
      let(:notification_settings) do
        Types::User::NotificationSettings.values - %i[friend_nickname_change]
      end

      it do
        expect { subject }.to_not change(Message, :count)
        is_expected.to be nil
      end
    end

    context 'allowed_notifications' do
      let(:notification_settings) { Types::User::NotificationSettings.values }

      it do
        expect { subject }.to change(Message, :count).by 1
        is_expected.to be_persisted
        is_expected.to have_attributes(
          from: bot,
          to: friend,
          kind: MessageType::NICKNAME_CHANGED,
          body: <<-BODY.squish.strip
            Твой друг [profile=#{target.id}]#{old_nickname}[/profile]
            изменил никнейм на [profile=#{target.id}]#{new_nickname}[/profile].
          BODY
        )
      end

      context 'antispam ignored' do
        subject(:notify_twice) do
          service.nickname_changed friend, old_nickname, new_nickname
          service.nickname_changed friend, old_nickname, new_nickname
        end

        it do
          expect { notify_twice }.to change(Message, :count).by 2
        end
      end
    end
  end

  describe '#round_finished' do
    let(:target) { create :contest_round, contest: contest }
    let(:contest) { create :contest, :with_topics }

    subject! { service.round_finished }

    it do
      expect(contest.topic.comments).to have(1).item
    end
  end

  describe '#contest_started' do
    let(:target) { create :contest, :with_topics }

    subject! { service.contest_started }

    it do
      expect(target.topic.comments).to have(1).item

      target.news_topics.each do |topic|
        expect(topic).to have_attributes(
          linked: target,
          type: 'Topics::NewsTopics::ContestStatusTopic',
          action: Types::Topic::ContestStatusTopic::Action[:started].to_s,
          value: nil,
          processed: false
        )
      end
    end
  end

  describe '#contest_finished' do
    let(:target) { create :contest, :with_topics }

    subject! { service.contest_finished }

    it do
      expect(target.topic.comments).to have(1).item
      
      target.news_topics.each do |topic|
        expect(topic).to have_attributes(
          linked: target,
          type: 'Topics::NewsTopics::ContestStatusTopic',
          action: Types::Topic::ContestStatusTopic::Action[:finished].to_s,
          value: nil,
          processed: false
        )
      end
    end
  end

  describe '#bad_email' do
    let(:target) { create :user }
    subject { service.bad_email }

    it do
      expect { subject }.to change(Message, :count).by 1
      is_expected.to be_persisted
      is_expected.to have_attributes(
        from: bot,
        to: target,
        kind: MessageType::NOTIFICATION
      )
    end
  end
end
