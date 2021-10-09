describe Messages::GenerateBody do
  let(:service) { Messages::GenerateBody.new message }
  subject { service.call }

  let(:user_from) { build_stubbed :user, nickname: 'from' }
  let(:user_to) { build_stubbed :user, nickname: 'to' }
  let(:linked) { nil }
  let(:body) { nil }
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
      let(:kind) { MessageType::PRIVATE }
      let(:body) { '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
      it { is_expected.to be_html_safe }
    end

    context 'notification' do
      let(:kind) { MessageType::NOTIFICATION }
      let(:body) { '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
    end

    context 'nickname_changed' do
      let(:kind) { MessageType::NICKNAME_CHANGED }
      let(:body) { '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
    end

    context 'anons' do
      let(:linked) { build :news_topic, action: 'anons', linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::ANONS }
      it { is_expected.to eq "Анонсировано аниме #{anime.name}" }
    end

    context 'ongoing' do
      let(:linked) { build :news_topic, action: 'ongoing', linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::ONGOING }
      it { is_expected.to eq "Начат показ аниме #{anime.name}" }
    end

    context 'episode' do
      let(:linked) { build :news_topic, action: 'episode', value: 5, linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::EPISODE }
      it { is_expected.to eq "Вышел 5 эпизод аниме #{anime.name}" }
    end

    context 'released' do
      let(:linked) { build :news_topic, action: 'released', linked: anime }
      let(:anime) { build_stubbed :anime, name: 'test' }
      let(:kind) { MessageType::RELEASED }
      it { is_expected.to eq "Завершён показ аниме #{anime.name}" }
    end

    context 'site_news' do
      let(:linked) { build :news_topic, body: '[b]test[/b]' }
      let(:kind) { MessageType::SITE_NEWS }
      it { is_expected.to eq '<strong>test</strong>' }

      context 'w/o topic' do
        let(:linked) { nil }
        let(:body) { 'test' }
        it { is_expected.to eq body }
      end
    end

    context 'profile_commented' do
      let(:kind) { MessageType::PROFILE_COMMENTED }
      it do
        is_expected.to eq(
          <<~HTML.squish
            Написал что-то в твоём
            <a class='b-link'
            href='#{Shikimori::PROTOCOL}://test.host/to'>профиле</a>.
          HTML
        )
      end
    end

    context 'friend_request' do
      let(:kind) { MessageType::FRIEND_REQUEST }

      context 'accepted' do
        let(:user_from) { create :user }
        let(:user_to) { create :user }
        let!(:friend_link) { create :friend_link, dst: user_from, src: user_to }

        it { is_expected.to eq 'Добавил тебя в список друзей.' }
      end

      context 'not accepted' do
        it do
          is_expected.to eq(
            'Добавил тебя в список друзей. Добавить его в твой список друзей в ответ?'
          )
        end
      end
    end

    context 'quoted_by_user' do
      let(:kind) { MessageType::QUOTED_BY_USER }
      let(:linked) { build_stubbed :topic, id: 1, title: 'test' }

      it do
        is_expected.to eq(
          <<~HTML.squish
            Написал <a class="b-link"
            href="#{Shikimori::PROTOCOL}://test.host/comments/1-test">что-то</a>
            тебе в топике
            <a href="#{UrlGenerator.instance.topic_url linked}"
            class="bubbled b-link"
            data-href="#{UrlGenerator.instance.topic_url linked}/tooltip">test</a>.
          HTML
        )
      end

      context 'in anime topic' do
        let(:linked) { build_stubbed :comment, id: 1, commentable: topic }
        let(:topic) { build_stubbed :anime_topic, id: 1, title: 'test', linked: anime }
        let(:anime) { build_stubbed :anime, id: 1 }

        it do
          is_expected.to eq(
            <<~HTML.squish
              Написал <a class="b-link"
              href="#{UrlGenerator.instance.comment_url linked}">что-то</a>
              тебе в топике
              <a href="#{UrlGenerator.instance.topic_url topic}#comment-1"
              class="bubbled b-link"
              data-href="#{UrlGenerator.instance.comment_url linked}/tooltip">Обсуждение аниме [anime]1[/anime]</a>.
            HTML
          )
        end
      end
    end

    context 'subscription_commented' do
      let(:kind) { MessageType::SUBSCRIPTION_COMMENTED }
      let(:linked) { build_stubbed :topic, id: 1, title: 'test' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            Новые сообщения в топике
            <a href="#{UrlGenerator.instance.topic_url linked}"
            class="bubbled b-link"
            data-href="#{UrlGenerator.instance.topic_url linked}/tooltip">test</a>.
          HTML
        )
      end
    end

    context 'warned' do
      let(:kind) { MessageType::WARNED }

      context 'no comment' do
        let(:linked) { build_stubbed :ban, comment: nil, comment_id: 99999 }
        it do
          is_expected.to eq(
            <<~HTML.squish
              Тебе вынесено предупреждение за комментарий (удалён).
              Причина: "moderator comment".
            HTML
          )
        end
      end

      context 'comment' do
        let(:offtopic_topic) { seed :offtopic_topic }
        let(:comment) { build_stubbed :comment }
        let(:linked) { build_stubbed :ban, comment: comment }
        it do
          is_expected.to eq(
            <<~HTML.squish
              Тебе вынесено предупреждение за комментарий в топике
              <a href="#{UrlGenerator.instance.topic_url offtopic_topic}#comment-#{comment.id}"
              class="bubbled b-link"
              data-href="#{UrlGenerator.instance.comment_url comment}/tooltip">offtopic</a>.
            HTML
          )
        end
      end
    end

    context 'banned' do
      let(:kind) { MessageType::BANNED }

      context 'no comment' do
        let(:linked) { build_stubbed :ban, comment: nil }
        it do
          is_expected.to eq(
            <<~HTML.squish
              Ты забанен на 3 часа. Причина: "moderator comment".
            HTML
          )
        end
      end

      context 'comment' do
        let(:offtopic_topic) { seed :offtopic_topic }
        let(:comment) { build_stubbed :comment, id: 1 }
        let(:linked) { build_stubbed :ban, comment: comment }
        it do
          is_expected.to eq(
            <<~HTML.squish
              Ты забанен на 3 часа за комментарий в топике
              <a href="#{UrlGenerator.instance.topic_url offtopic_topic}#comment-#{comment.id}"
              class="bubbled b-link"
              data-href="#{UrlGenerator.instance.comment_url comment}/tooltip">offtopic</a>.
            HTML
          )
        end
      end
    end

    context 'club_request' do
      let(:kind) { MessageType::CLUB_REQUEST }
      let(:club) { create :club, id: 1, name: 'test' }
      let(:linked) { build_stubbed :club_invite, club: club }
      it do
        is_expected.to eq(
          <<~HTML.squish
            Приглашение на вступление в клуб
            <a href="#{Shikimori::PROTOCOL}://shikimori.test/clubs/1-test"
            title="test" class="b-link">test</a>.
          HTML
        )
      end
    end

    context 'version_accepted' do
      let(:kind) { MessageType::VERSION_ACCEPTED }
      let(:anime) { create :anime, id: 1, name: 'test', russian: '' }
      let(:linked) { create :version, item: anime, id: 1 }
      let(:attrs) { { id: anime.id, type: 'anime', name: anime.name, russian: anime.russian } }
      let(:data_attrs) { attrs.to_json.gsub '"', '&quot;' }

      it do
        is_expected.to eq(
          <<~HTML.squish
            Твоя <a href="#{Shikimori::PROTOCOL}://shikimori.test/moderations/versions/1"
            title="правка" class="bubbled b-link"
            data-tooltip_url="#{Shikimori::PROTOCOL}://shikimori.test/moderations/versions/1/tooltip">правка</a>
            для <a href="#{Shikimori::PROTOCOL}://test.host/animes/1-test"
            title="test" class="bubbled b-link"
            data-tooltip_url="#{Shikimori::PROTOCOL}://test.host/animes/1-test/tooltip"
            data-attrs="#{data_attrs}">test</a> принята.
          HTML
        )
      end
    end

    context 'version_rejected' do
      let(:kind) { MessageType::VERSION_REJECTED }
      let(:anime) { create :anime, id: 1, name: 'test', russian: '' }
      let(:linked) { create :version, item: anime, id: 1, moderator: user_from }
      let(:attrs) { { id: anime.id, type: 'anime', name: anime.name, russian: anime.russian } }
      let(:data_attrs) { attrs.to_json.gsub '"', '&quot;' }

      context 'with reason' do
        let(:body) { 'zxc' }
        it do
          is_expected.to eq(
            <<~HTML.squish
              Твоя <a href="#{Shikimori::PROTOCOL}://shikimori.test/moderations/versions/1"
              title="правка" class="bubbled b-link"
              data-tooltip_url="#{Shikimori::PROTOCOL}://shikimori.test/moderations/versions/1/tooltip">правка</a>
              для <a href="#{Shikimori::PROTOCOL}://test.host/animes/1-test"
              title="test" class="bubbled b-link"
              data-tooltip_url="#{Shikimori::PROTOCOL}://test.host/animes/1-test/tooltip"
              data-attrs="#{data_attrs}">test</a>
              отклонена по причине:
              <div class="b-quote" data-attrs="from"><div class="quoteable">from</div><div
              class="quote-content">zxc</div></div>
            HTML
          )
        end
      end

      context 'without reason' do
        it do
          is_expected.to eq(
            <<~HTML.squish
              Твоя <a href="#{Shikimori::PROTOCOL}://shikimori.test/moderations/versions/1"
              title="правка" class="bubbled b-link"
              data-tooltip_url="#{Shikimori::PROTOCOL}://shikimori.test/moderations/versions/1/tooltip">правка</a>
              для <a href="#{Shikimori::PROTOCOL}://test.host/animes/1-test"
              title="test" class="bubbled b-link"
              data-tooltip_url="#{Shikimori::PROTOCOL}://test.host/animes/1-test/tooltip"
              data-attrs="#{data_attrs}">test</a>
              отклонена.
            HTML
          )
        end
      end
    end

    context 'contest_started' do
      let(:kind) { MessageType::CONTEST_STARTED }
      let(:linked) { create :contest, id: 1, title_ru: 'foo', title_en: 'bar' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <span class="translated-after" data-text-ru="Турнир" data-text-en="Contest"></span>
            <a href="#{Shikimori::PROTOCOL}://test.host/contests/1-foo"
            class="b-link translated-after" data-text-ru="foo" data-text-en="bar"></a>
            <span class="translated-after" data-text-ru="начат" data-text-en="started"></span>.
          HTML
        )
      end
    end

    context 'contest_finished' do
      let(:kind) { MessageType::CONTEST_FINISHED }
      let(:linked) { create :contest, id: 1, title_ru: 'foo', title_en: 'bar' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <span class="translated-after" data-text-ru="Турнир" data-text-en="Contest"></span>
            <a href="#{Shikimori::PROTOCOL}://test.host/contests/1-foo"
            class="b-link translated-after" data-text-ru="foo" data-text-en="bar"></a>
            <span class="translated-after" data-text-ru="завершён" data-text-en="finished"></span>.
          HTML
        )
      end
    end

    context 'club_broadcast' do
      let(:kind) { MessageType::CLUB_BROADCAST }
      let(:linked) { create :comment, commentable: club.topics.first, body: '[b]z[/b]' }
      let(:club) { create :club, :with_topics }

      it do
        is_expected.to eq '<strong>z</strong>'
      end
    end
  end
end
