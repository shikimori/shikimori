describe Messages::GenerateBody do
  let(:service) { Messages::GenerateBody.new message }
  subject { service.call }

  let(:user_from) { build_stubbed :user, nickname: 'from' }
  let(:user_to) { build_stubbed :user, nickname: 'to' }
  let(:linked) {}
  let(:body) {}
  let(:read) { false }
  let(:message) do
    build :message,
      kind: kind,
      from: user_from,
      to: user_to,
      linked: linked,
      body: body,
      read: read
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

    context 'anons' do
      let(:linked) { build :news_topic, action: 'anons', linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::Anons }
      it { is_expected.to eq "Анонсировано аниме #{anime.name}" }
    end

    context 'ongoing' do
      let(:linked) { build :news_topic, action: 'ongoing', linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::Ongoing }
      it { is_expected.to eq "Начат показ аниме #{anime.name}" }
    end

    context 'episode' do
      let(:linked) { build :news_topic, action: 'episode', value: 5, linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::Episode }
      it { is_expected.to eq "Вышел 5 эпизод аниме #{anime.name}" }
    end

    context 'released' do
      let(:linked) { build :news_topic, action: 'released', linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::Released }
      it { is_expected.to eq "Завершён показ аниме #{anime.name}" }
    end

    context 'site_news' do
      let(:linked) { build :news_topic, body: '[b]test[/b]' }
      let(:kind) { MessageType::SiteNews }
      it { is_expected.to eq '<strong>test</strong>' }
    end

    context 'profile_commented' do
      let(:kind) { MessageType::ProfileCommented }
      it do
        is_expected.to eq(
          "Написал что-то в вашем <a class='b-link' href='//test.host/to'>профиле</a>."
        )
      end
    end

    context 'friend_request' do
      let(:kind) { MessageType::FriendRequest }

      context 'accepted' do
        let!(:friend_link) { create :friend_link, dst: user_from, src: user_to }
        it { is_expected.to eq 'Добавил вас в список друзей.' }
      end

      context 'not accepted' do
        it do
          is_expected.to eq(
            'Добавил вас в список друзей. Добавить его в свой список друзей в ответ?'
          )
        end
      end
    end

    context 'quoted_by_user' do
      let(:kind) { MessageType::QuotedByUser }
      let(:linked) { build_stubbed :topic, id: 1, title: 'test' }
      it do
        is_expected.to eq(
          'Написал <a class="b-link" href="//test.host/comments/1-test">что-то</a> вам в топике <a href="//test.host/forum/offtopic/1-test">test</a>.'
        )
      end
    end

    context 'subscription_commented' do
      let(:kind) { MessageType::SubscriptionCommented }
      let(:linked) { build_stubbed :topic, id: 1, title: 'test' }
      it do
        is_expected.to eq(
          'Новые сообщения в топике <a href="//test.host/forum/offtopic/1-test">test</a>.'
        )
      end
    end

    context 'warned' do
      let(:kind) { MessageType::Warned }

      context 'no comment' do
        let(:linked) { build_stubbed :ban }
        it do
          is_expected.to eq(
            'Вам вынесено предупреждение за удалённый комментарий. Причина: "moderator comment".'
          )
        end
      end

      context 'comment' do
        let(:offtopic_topic) { seed :offtopic_topic }
        let(:comment) { build_stubbed :comment }
        let(:linked) { build_stubbed :ban, comment: comment }
        it do
          is_expected.to eq(
            'Вам вынесено предупреждение за комментарий в топике '\
            "<a href=\"//test.host/forum/offtopic/#{offtopic_topic.to_param}#comment-#{comment.id}\""\
            ' class="bubbled b-link" '\
            "data-href=\"//test.host/comments/#{comment.id}\">offtopic</a>."
          )
        end
      end
    end

    context 'banned' do
      let(:kind) { MessageType::Banned }

      context 'no comment' do
        let(:linked) { build_stubbed :ban }
        it do
          is_expected.to eq(
            'Вы забанены на 3 часа. Причина: "moderator comment".'
          )
        end
      end

      context 'comment' do
        let(:offtopic_topic) { seed :offtopic_topic }
        let(:comment) { build_stubbed :comment, id: 1 }
        let(:linked) { build_stubbed :ban, comment: comment }
        it do
          is_expected.to eq(
            'Вы забанены на 3 часа за комментарий в топике '\
            "<a href=\"//test.host/forum/offtopic/#{offtopic_topic.to_param}#comment-#{comment.id}\""\
            ' class="bubbled b-link" '\
            "data-href=\"//test.host/comments/#{comment.id}\">offtopic</a>."
          )
        end
      end
    end

    context 'club_request' do
      let(:kind) { MessageType::ClubRequest }
      let(:club) { create :club, id: 1, name: 'test' }
      let(:linked) { build_stubbed :club_invite, club: club }
      it do
        is_expected.to eq(
          'Приглашение на вступление в клуб <a href="//shikimori.org/clubs/1-test" title="" class="b-link">test</a>.'
        )
      end
    end

    context 'version_accepted' do
      let(:kind) { MessageType::VersionAccepted }
      let(:anime) { create :anime, id: 1, name: 'test' }
      let(:linked) { create :version, item: anime, id: 1 }
      it do
        is_expected.to eq(
          'Ваша <a href="//shikimori.org/moderations/versions/1" title="правка" class="bubbled b-link" data-tooltip_url="//shikimori.org/moderations/versions/1/tooltip">правка</a> для <a href="//test.host/animes/1-test" title="test" class="bubbled b-link" data-tooltip_url="//test.host/animes/1-test/tooltip">test</a> принята.'
        )
      end
    end

    context 'version_rejected' do
      let(:kind) { MessageType::VersionRejected }
      let(:anime) { create :anime, id: 1, name: 'test' }
      let(:linked) { create :version, item: anime, id: 1, moderator: user_from }

      context 'with reason' do
        let(:body) { 'zxc' }
        it do
          is_expected.to eq(
            'Ваша <a href="//shikimori.org/moderations/versions/1" title="правка" class="bubbled b-link" data-tooltip_url="//shikimori.org/moderations/versions/1/tooltip">правка</a> для <a href="//test.host/animes/1-test" title="test" class="bubbled b-link" data-tooltip_url="//test.host/animes/1-test/tooltip">test</a> отклонена по причине: <div class="b-quote"><div class="quoteable">from <span class="text-ru">написал:</span><span class="text-en" data-text="wrote:"></span></div>zxc</div>'
          )
        end
      end

      context 'without reason' do
        it do
          is_expected.to eq(
            'Ваша <a href="//shikimori.org/moderations/versions/1" title="правка" class="bubbled b-link" data-tooltip_url="//shikimori.org/moderations/versions/1/tooltip">правка</a> для <a href="//test.host/animes/1-test" title="test" class="bubbled b-link" data-tooltip_url="//test.host/animes/1-test/tooltip">test</a> отклонена.'
          )
        end
      end
    end

    context 'contest_finished' do
      let(:kind) { MessageType::ContestFinished }
      let(:linked) { create :contest, id: 1, title_ru: 'foo', title_en: 'bar' }
      it do
        is_expected.to eq(
          '<span class="translated-after" '\
            'data-text-ru="Турнир" '\
            'data-text-en="Contest"></span> '\
            '<a href="//test.host/contests/1-foo" '\
            'class="b-link translated-after" '\
            'data-text-ru="foo" '\
            'data-text-en="bar"></a> '\
            '<span class="translated-after" '\
            'data-text-ru="завершён" '\
            'data-text-en="has finished"></span>.'
        )
      end
    end

    context 'club_broadcast' do
      let(:kind) { MessageType::ClubBroadcast }
      let(:linked) { create :comment, commentable: club.topics.first, body: '[b]z[/b]' }
      let(:club) { create :club, :with_topics }

      it do
        is_expected.to eq '<strong>z</strong>'
      end
    end
  end
end
