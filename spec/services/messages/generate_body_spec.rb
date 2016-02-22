describe Messages::GenerateBody do
  let(:service) { Messages::GenerateBody.new message }
  subject { service.call }

  let(:user_from) { build_stubbed :user, nickname: 'from' }
  let(:user_to) { build_stubbed :user, nickname: 'to' }
  let(:linked) { }
  let(:body) { }
  let(:read) { false }
  let(:message) do
    build :message, {
      kind: kind,
      from: user_from,
      to: user_to,
      linked: linked,
      body: body,
      read: read
    }
  end

  describe '#call' do
    context 'private' do
      let(:kind) { MessageType::Private }
      let(:body) { '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
      it { is_expected.to be_html_safe }
    end

    context 'notification' do
      let(:kind) { MessageType::Notification }
      let(:body) { '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
    end

    context 'nickname_changed' do
      let(:kind) { MessageType::NicknameChanged }
      let(:body) { '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
    end

    context 'ongoing' do
      let(:linked) { build :news_topic, action: 'ongoing' }
      let(:kind) { MessageType::Ongoing }
      it { is_expected.to eq 'онгоинг' }
    end

    context 'anons' do
      let(:linked) { build :news_topic, action: 'anons' }
      let(:kind) { MessageType::Anons }
      it { is_expected.to eq 'анонс' }
    end

    context 'episode' do
      let(:linked) { build :news_topic, action: 'episode', value: 5 }
      let(:kind) { MessageType::Episode }
      it { is_expected.to eq 'эпизод' }
    end

    context 'released' do
      let(:linked) { build :news_topic, action: 'released' }
      let(:kind) { MessageType::Released }
      it { is_expected.to eq 'релиз' }
    end

    context 'site_news' do
      let(:linked) { build :news_topic, body: '[b]test[/b]' }
      let(:kind) { MessageType::SiteNews }
      it { is_expected.to eq '<strong>test</strong>' }
    end

    context 'profile_commented' do
      let(:kind) { MessageType::ProfileCommented }
      it { is_expected.to eq "Написал что-то в вашем <a class='b-link' href='http://test.host/to'>профиле</a>..." }
    end

    context 'friend_request' do
      let(:kind) { MessageType::FriendRequest }

      context 'read' do
        let(:read) { true }
        it { is_expected.to eq 'Добавил вас в список друзей.' }
      end

      context 'not read' do
        it { is_expected.to eq 'Добавил вас в список друзей. Добавить его в свой список друзей в ответ?' }
      end
    end

    context 'quoted_by_user' do
      let(:kind) { MessageType::QuotedByUser }
      let(:linked) { build_stubbed :topic, id: 1, title: 'test' }
      it { is_expected.to eq "Написал что-то вам в топике <a href=\"http://test.host/forum/offtopic/1-test\">test</a>." }
    end

    context 'subscription_commented' do
      let(:kind) { MessageType::SubscriptionCommented }
      let(:linked) { build_stubbed :topic, id: 1, title: 'test' }
      it { is_expected.to eq "Новые сообщения в топике <a href=\"http://test.host/forum/offtopic/1-test\">test</a>." }
    end

    context 'warned' do
      let(:kind) { MessageType::Warned }

      context 'no comment' do
        let(:linked) { build_stubbed :ban }
        it { is_expected.to eq "Вам вынесено предупреждение за удалённый комментарий. Причина: \"moderator comment\"." }
      end

      context 'comment' do
        let(:topic) { build_stubbed :topic, id: 1, title: 'test' }
        let(:comment) { build_stubbed :comment, id: 1 }
        let(:linked) { build_stubbed :ban, comment: comment }
        it { is_expected.to eq "Вам вынесено предупреждение за комментарий в топике <a href=\"http://test.host/forum/offtopic/78643875-topic_1#comment-1\" class=\"bubbled b-link\" data-href=\"http://test.host/comments/1\">topic_1</a>.." }
      end
    end

    context 'banned' do
      let(:kind) { MessageType::Banned }

      context 'no comment' do
        let(:linked) { build_stubbed :ban }
        it { is_expected.to eq "Вы забанены на 3 часа.. Причина: \"moderator comment\"." }
      end

      context 'comment' do
        let(:topic) { build_stubbed :topic, id: 1, title: 'test' }
        let(:comment) { build_stubbed :comment, id: 1 }
        let(:linked) { build_stubbed :ban, comment: comment }
        it { is_expected.to eq "Вы забанены на 3 часа. за комментарий в топике <a href=\"http://test.host/forum/offtopic/78643875-topic_1#comment-1\" class=\"bubbled b-link\" data-href=\"http://test.host/comments/1\">topic_1</a>.." }
      end
    end

    context 'club_request' do
      let(:kind) { MessageType::ClubRequest }
      let(:club) { create :club, id: 1, name: 'test' }
      let(:linked) { build_stubbed :club_invite, club: club }
      it { is_expected.to eq "Приглашение на вступление в клуб <a href=\"http://shikimori.org/clubs/1-test\" title=\"\" class=\"b-link\">test</a>." }
    end

    context 'version_accepted' do
      let(:kind) { MessageType::VersionAccepted }
      let(:anime) { create :anime, id: 1, name: 'test' }
      let(:linked) { create :version, item: anime, id: 1 }
      it { is_expected.to eq "Ваша <a href=\"http://shikimori.org/moderations/versions/1\" title=\"правка\" class=\"bubbled b-link\" data-tooltip_url=\"http://shikimori.org/moderations/versions/1/tooltip\">правка</a> для <a href=\"http://shikimori.org/animes/1-test\" title=\"\" class=\"bubbled b-link\" data-tooltip_url=\"http://shikimori.org/animes/1-test/tooltip\">test</a> принята." }
    end

    context 'version_rejected' do
      let(:kind) { MessageType::VersionRejected }
      let(:anime) { create :anime, id: 1, name: 'test' }
      let(:linked) { create :version, item: anime, id: 1, moderator: user_from }

      context 'with reason' do
        let(:body) { 'zxc' }
        it { is_expected.to eq "Ваша <a href=\"http://shikimori.org/moderations/versions/1\" title=\"правка\" class=\"bubbled b-link\" data-tooltip_url=\"http://shikimori.org/moderations/versions/1/tooltip\">правка</a> для <a href=\"http://shikimori.org/animes/1-test\" title=\"\" class=\"bubbled b-link\" data-tooltip_url=\"http://shikimori.org/animes/1-test/tooltip\">test</a> отклонена по причине: <div class=\"b-quote\"><div class=\"quoteable\">from написал:</div>zxc</div>" }
      end

      context 'without reason' do
        it { is_expected.to eq "Ваша <a href=\"http://shikimori.org/moderations/versions/1\" title=\"правка\" class=\"bubbled b-link\" data-tooltip_url=\"http://shikimori.org/moderations/versions/1/tooltip\">правка</a> для <a href=\"http://shikimori.org/animes/1-test\" title=\"\" class=\"bubbled b-link\" data-tooltip_url=\"http://shikimori.org/animes/1-test/tooltip\">test</a> отклонена." }
      end
    end

    context 'contest_finished' do
      let(:kind) { MessageType::ContestFinished }
      let(:linked) { create :contest, id: 1, title: 'asd' }
      it { is_expected.to eq "Опрос <a href=\"http://test.host/contests/1-\" class=\"b-link\">asd</a> завершён." }
    end
  end
end
