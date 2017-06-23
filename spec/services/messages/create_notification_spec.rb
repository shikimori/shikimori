describe Messages::CreateNotification do
  let(:service) { Messages::CreateNotification.new target }

  describe '#user_registered' do
    let(:target) { build_stubbed :user }
    let!(:sender) { seed :user }
    it do
      expect { service.user_registered }.to change(target.messages, :count).by 1
    end
  end

  describe '#moderatable_banned' do
    let(:target) { create :review, :with_topics, user: author, approver: approver }
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
          kind: MessageType::Notification,
          linked: target,
          body: <<-BODY.squish.strip
            Ваша [entry=#{target.topic(:ru).id}]рецензия[/entry]
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
          kind: MessageType::Notification,
          linked: target,
          body: <<-BODY.squish.strip
            Ваша [entry=#{target.topic(:ru).id}]рецензия[/entry]
            перенесена в оффтоп.
          BODY
        )
      end
    end
  end

  describe '#nickname_changed' do
    let(:target) { seed :user }
    let(:friend) { create :user, notifications: notifications }
    let(:old_nickname) { 'old_nick' }
    let(:new_nickname) { 'new_nick' }

    subject(:message) { service.nickname_changed friend, old_nickname, new_nickname }

    context 'disabled_notifications' do
      let(:notifications) do
        User::DEFAULT_NOTIFICATIONS - User::NICKNAME_CHANGE_NOTIFICATIONS
      end

      it do
        expect { subject }.to_not change(Message, :count)
        is_expected.to be nil
      end
    end

    context 'allowed_notifications' do
      before { allow(BotsService).to receive(:get_poster).and_return bot }

      let(:notifications) { User::DEFAULT_NOTIFICATIONS }
      let(:bot) { seed :user }

      it do
        expect { subject }.to change(Message, :count).by 1
        is_expected.to be_persisted
        is_expected.to have_attributes(
          from: bot,
          to: friend,
          kind: MessageType::NicknameChanged,
          body: <<-BODY.squish.strip
            Ваш друг [profile=#{target.id}]#{old_nickname}[/profile]
            изменил никнейм на [profile=#{target.id}]#{new_nickname}[/profile].
          BODY
        )
      end

      it 'ignores antispam' do
        expect(proc do
          service.nickname_changed friend, old_nickname, new_nickname
          service.nickname_changed friend, old_nickname, new_nickname
        end).to change(Message, :count).by 2
      end
    end
  end

  describe '#round_finished' do
    let(:target) { create :contest_round, contest: contest }
    let(:contest) { create :contest, :with_topics }

    before { service.round_finished }

    it do
      contest.topics.each do |topic|
        expect(topic.comments).to have(1).item
      end
    end
  end

  describe '#contest_finished' do
    let(:target) { create :contest, :with_topics }
    let!(:round) { create :contest_round, contest: target }
    let!(:match) { create :contest_match, round: round }

    before { service.contest_finished }

    it do
      target.topics.each do |topic|
        expect(topic.comments).to have(1).item
      end
      target.news_topics.each do |topic|
        expect(topic).to have_attributes(
          linked: target,
          action: nil,
          value: nil,
          processed: false
        )
      end
    end
  end
end
