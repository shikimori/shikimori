require 'cancan/matchers'

describe AnimeVideo do
  describe 'relations' do
    it { is_expected.to belong_to :anime }
    it { is_expected.to belong_to :author }
    it { is_expected.to have_many(:reports).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :anime }
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to validate_presence_of :source }
    it { is_expected.to validate_presence_of :kind }
    it { is_expected.to validate_numericality_of(:episode).is_greater_than_or_equal_to(0) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in :raw, :subtitles, :fandub, :unknown }
    it { is_expected.to enumerize(:language).in :russian, :english, :original, :unknown }
    it { is_expected.to enumerize(:quality).in :bd, :web, :tv, :dvd, :unknown }
  end

  describe 'scopes' do
    describe '#available' do
      subject { AnimeVideo.available }

      context 'filter by video status' do
        before do
          states.each do |s|
            create :anime_video, state: s, anime: create(:anime)
          end
        end

        context 'good states' do
          let(:states) { ['working', 'uploaded' ] }
          it { is_expected.to have(states.size).items }
        end

        context 'bad states' do
          let(:states) { ['broken', 'wrong', 'banned', 'copyrighted' ] }
          it { is_expected.to be_empty }
        end
      end
    end

    describe '#allowed_play' do
      subject { AnimeVideo.allowed_play }

      context 'true' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: false) }
          it { is_expected.to have(1).item }
        end

        context 'by_reting' do
          before { create :anime_video, anime: create(:anime, rating: :none) }
          it { is_expected.to have(1).item }
        end
      end

      context 'false' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: true) }
          it { is_expected.to be_blank }
        end

        context 'by_rating' do
          before do
            create :anime_video, anime: create(:anime, rating: Anime::ADULT_RATING)
          end

          it { is_expected.to be_blank }
        end
      end
    end

    describe '#allowed_xplay' do
      subject { AnimeVideo.allowed_xplay }

      context 'false' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: false) }
          it { is_expected.to be_blank }
        end

        context 'by_reting' do
          before { create :anime_video, anime: create(:anime, rating: :none) }
          it { is_expected.to be_blank }
        end
      end

      context 'true' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: true) }
          it { is_expected.to have(1).item }
        end

        context 'by_rating' do
          before { create :anime_video, anime: create(:anime, rating: Anime::ADULT_RATING) }
          it { is_expected.to have(1).item }
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      before { anime_video.save }

      describe '#check_ban' do
        subject { anime_video.banned? }
        let(:anime_video) { build :anime_video, url: url }

        context 'in_ban' do
          let(:url) { 'http://v.kiwi.kz/v2/9l7tsj8n3has/' }
          it { is_expected.to be_truthy }
        end

        context 'no_ban' do
          let(:url) { 'http://vk.com/j8n3/' }
          it { is_expected.to be_falsy }
        end
      end

      describe '#copyrighted' do
        let(:anime_video) { build :anime_video, anime: create(:anime, id: anime_id) }
        subject { anime_video.copyrighted? }

        context 'ban' do
          let(:anime_id) { AnimeVideo::CopyrightBanAnimeIDs.first }
          it { is_expected.to be_truthy }
        end

        context 'not_ban' do
          let(:anime_id) { 1 }
          it { is_expected.to be_falsy }
        end
      end
    end

    describe 'after_create' do
      describe '#create_episode_notificaiton' do
        let(:anime) { build_stubbed :anime }
        let(:url_1) { 'http://foo/1' }
        let(:url_2) { 'http://foo/2' }

        context 'new_video' do
          subject { EpisodeNotification.first }
          let!(:anime_video) { create :anime_video, :with_notification, anime: anime, kind: :raw }

          its(:is_raw) { is_expected.to be_truthy }
          its(:is_subtitles) { is_expected.to be_nil }
          its(:is_fandub) { is_expected.to be_nil }
          it { expect(EpisodeNotification.all).to have(1).item }
        end

        context 'new_episode' do
          let!(:anime_video_1) { create :anime_video, :with_notification, anime: anime, episode: 1, url: url_1 }
          let!(:anime_video_2) { create :anime_video, :with_notification, anime: anime, episode: 2, url: url_2 }
          it { expect(EpisodeNotification.all).to have(2).items }
        end

        context 'not_new_episode_but_other_kind' do
          subject { EpisodeNotification.first }
          let!(:anime_video_1) { create :anime_video, :with_notification, anime: anime, kind: :raw, url: url_1 }
          let!(:anime_video_2) { create :anime_video, :with_notification, anime: anime, kind: :subtitles, url: url_2 }

          its(:is_raw) { is_expected.to be_truthy }
          its(:is_subtitles) { is_expected.to be_truthy }
          its(:is_fandub) { is_expected.to be_nil }
          it { expect(EpisodeNotification.all).to have(1).item }
        end

        context 'not_new_episode' do
          let!(:anime_video_1) { create :anime_video, :with_notification, anime: anime, url: url_1 }
          let!(:anime_video_2) { create :anime_video, :with_notification, anime: anime, url: url_2 }
          it { expect(EpisodeNotification.all).to have(1).item }
        end

        #context 'not need notification if video kind is unknown' do
          #let!(:anime_video_1) { create :anime_video, :with_notification, anime: anime, url: url_1, kind: :unknown }
          #it { expect(EpisodeNotification.all).to be_empty }
        #end
      end
    end
  end

  describe 'state_machine' do
    subject(:video) { create :anime_video }

    context 'initial' do
      it { is_expected.to be_working }
    end

    context 'broken' do
      before { video.broken }
      it { is_expected.to be_broken }
    end

    context 'wrong' do
      before { video.wrong }
      it { is_expected.to be_wrong }
    end

    context 'ban' do
      before { video.ban }
      it { is_expected.to be_banned }
    end

    context 'FIX : https://github.com/morr/shikimori/issues/428' do
      subject(:video) { create(:anime_video, state: 'rejected') }
      before { video.broken }
      it { is_expected.to be_broken }
    end

    context 'Fix : https://github.com/morr/shikimori/issues/440' do
      subject(:video) { create(:anime_video, state: 'rejected') }
      before { video.wrong }
      it { is_expected.to be_wrong }
    end

    describe 'remove_episode_notification' do
      [:fandub, :raw, :subtitles].each do |kind|
        [:broken, :wrong, :ban].each do |action|
          context "#{kind} #{action}" do
            let(:video) { create(:anime_video, kind: kind) }
            before do
              create(
                :episode_notification,
                anime_id: video.anime_id,
                episode: video.episode,
                is_raw: video.raw?,
                is_fandub: video.fandub?,
                is_subtitles: video.subtitles?
              )
            end

            subject { EpisodeNotification.last }

            context 'single video' do
              before { video.send(action) }
              it { expect(subject.send("is_#{kind}")).to eq false }
            end

            context 'not single video' do
              before { create(:anime_video, anime: video.anime, episode: video.episode, kind: kind) }
              before { video.send(action) }
              it { expect(subject.send("is_#{kind}")).to eq true }
            end
          end
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#url=' do
      let(:video) { build :anime_video, url: url }

      describe 'new record' do
        context 'normal url' do
          let(:url) { 'http://vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16&hd=2' }
          it { expect(video.url).to eq url }
        end

        context 'url w/o http' do
          let(:url) { 'vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16&hd=2' }
          it { expect(video.url).to eq "http://#{url}" }
        end
      end

      describe 'persisted video' do
        let(:video) { build_stubbed :anime_video, url: url }
        let(:url) { 'http://rutube.ru/video/ef370e68cd9687a30ea67a68658c6ef8/?ref=logo' }
        before { video.url = new_url }

        describe 'indirect url' do
          let(:new_url) { '<iframe width="720" height="405" src="//rutube.ru/play/embed/3599097" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>' }
          it { expect(video.url).to eq 'http://rutube.ru/play/embed/3599097' }
        end

        describe 'direct url' do
          let(:new_url) { 'http://rutube.ru/play/embed/3599097' }
          it { expect(video.url).to eq 'http://rutube.ru/play/embed/3599097' }
        end
      end
    end

    describe '#hosting' do
      subject { build(:anime_video, url: url).hosting }

      context 'valid_url' do
        let(:url) { 'http://vk.com/video_ext.php?oid=1' }
        it { is_expected.to eq 'vk.com' }
      end

      context 'remove_www' do
        let(:url) { 'http://www.vk.com?id=1' }
        it { is_expected.to eq 'vk.com' }
      end

      context 'second_level_domain' do
        let(:url) { 'http://www.foo.bar.com/video?id=1' }
        it { is_expected.to eq 'bar.com' }
      end

      context 'alias_vk_com' do
        let(:url) { 'http://vkontakte.ru/video?id=1' }
        it { is_expected.to eq 'vk.com' }
      end
    end

    describe '#vk?' do
      subject { video.vk? }
      let(:video) { build :anime_video, url: url }

      context 'true' do
        let(:url) { 'http://www.vk.com?id=1' }
        it { is_expected.to be_truthy }
      end

      context 'false' do
        let(:url) { 'http://www.foo.bar.com/video?id=1' }
        it { is_expected.to be_falsy }
      end
    end

    describe '#allowed?' do
      context 'true' do
        ['working', 'uploaded'].each do |state|
          it { expect(build(:anime_video, state: state).allowed?).to be_truthy }
        end
      end

      context 'false' do
        ['broken', 'wrong', 'banned'].each do |state|
          it { expect(build(:anime_video, state: state).allowed?).to be_falsy }
        end
      end
    end

    describe '#copyright_ban' do
      before { stub_const('AnimeVideo::CopyrightBanAnimeIDs', [2]) }
      let(:anime_video) { build :anime_video, anime_id: anime_id }
      subject { anime_video.copyright_ban? }

      context 'ban' do
        let(:anime_id) { AnimeVideo::CopyrightBanAnimeIDs.first }
        it { is_expected.to be_truthy }
      end

      context 'not_ban' do
        let(:anime_id) { 1 }
        it { is_expected.to be_falsy }
      end
    end

    describe '#uploader' do
      let(:anime_video) { build_stubbed :anime_video, state: state }
      let(:user) { create :user, :user, nickname: 'foo' }
      subject { anime_video.uploader }

      context 'with_uploader' do
        let(:state) { 'uploaded' }
        let(:kind) { state }
        let(:anime_video) { create :anime_video, state: state }
        let!(:anime_video_report) { create :anime_video_report, anime_video: anime_video, kind: kind, user: user }

        it { is_expected.to eq user }
      end

      context 'without_uploader' do
        context 'working' do
          let(:state) { 'working' }
          it { is_expected.to be_nil }
        end

        context 'uploaded_without_report' do
          let(:state) { 'uploaded' }
          it { is_expected.to be_nil }
        end
      end
    end

    describe '#author_name' do
      subject(:anime_video) { build_stubbed :anime_video, author: author }

      context 'no author' do
        let(:author) { }
        its(:author_name) { is_expected.to be_nil }
      end

      context 'with author' do
        let(:author) { build_stubbed :anime_video_author }
        its(:author_name) { is_expected.to eq author.name }
      end
    end

    describe '#author_name=' do
      subject(:anime_video) { build_stubbed :anime_video }
      let!(:author) { }
      let(:author_name) { 'fofofo' }
      before { anime_video.author_name = author_name }

      context 'new author' do
        its(:author_name) { is_expected.to eq author_name }
      end

      context 'present author' do
        let(:author) { create :anime_video_author, name: author_name }
        its(:author) { is_expected.to eq author }
      end
    end
  end

  describe 'permissions' do
    subject { Ability.new user }
    let(:uploaded_video) { build :anime_video, state: 'uploaded' }
    let(:working_video) { build :anime_video, state: 'working' }
    let(:broken_video) { build :anime_video, state: 'broken' }
    let(:banned_video) { build :anime_video, state: 'banned' }
    let(:copyrighted_video) { build :anime_video, state: 'copyrighted' }

    describe 'guest' do
      let(:user) { }
      it { is_expected.to be_able_to :new, uploaded_video }
      it { is_expected.to be_able_to :create, uploaded_video }

      it { is_expected.to_not be_able_to :new, working_video }
      it { is_expected.to_not be_able_to :create, working_video }
      it { is_expected.to_not be_able_to :new, broken_video }
      it { is_expected.to_not be_able_to :create, broken_video }

      it { is_expected.to_not be_able_to :edit, uploaded_video }
      it { is_expected.to_not be_able_to :update, uploaded_video }
      it { is_expected.to_not be_able_to :edit, working_video }
      it { is_expected.to_not be_able_to :update, working_video }
    end

    describe 'user' do
      let(:user) { build_stubbed :user, :user }

      it { is_expected.to be_able_to :new, uploaded_video }
      it { is_expected.to be_able_to :create, uploaded_video }

      it { is_expected.to_not be_able_to :new, working_video }
      it { is_expected.to_not be_able_to :create, working_video }
      it { is_expected.to_not be_able_to :new, broken_video }
      it { is_expected.to_not be_able_to :create, broken_video }

      it { is_expected.to_not be_able_to :destroy, uploaded_video }

      it { is_expected.to be_able_to :edit, uploaded_video }
      it { is_expected.to be_able_to :update, uploaded_video }
      it { is_expected.to be_able_to :edit, working_video }
      it { is_expected.to be_able_to :update, working_video }
    end

    describe 'video uploader' do
      let(:user) { create :user, :user }
      let(:video) { build_stubbed :anime_video, created_at: created_at, state: 'uploaded' }
      let!(:upload_report) { create :anime_video_report, anime_video: video, user: user, kind: 'uploaded' }

      context 'video created long ago' do
        let(:created_at) { 1.week.ago - 1.day }
        it { is_expected.to_not be_able_to :destroy, video }
      end

      context 'video created not long ago' do
        let(:created_at) { 1.week.ago + 1.day }
        it { is_expected.to be_able_to :destroy, video }
      end
    end

    describe 'video_moderator' do
      let(:user) { build_stubbed :user, :video_moderator }
      it { is_expected.to be_able_to :new, uploaded_video }
      it { is_expected.to be_able_to :create, uploaded_video }

      it { is_expected.to be_able_to :edit, uploaded_video }
      it { is_expected.to be_able_to :update, uploaded_video }
      it { is_expected.to be_able_to :edit, working_video }
      it { is_expected.to be_able_to :update, working_video }
      it { is_expected.to be_able_to :edit, broken_video }
      it { is_expected.to be_able_to :update, broken_video }

      it { is_expected.to_not be_able_to :edit, banned_video }
      it { is_expected.to_not be_able_to :update, banned_video }
      it { is_expected.to_not be_able_to :edit, copyrighted_video }
      it { is_expected.to_not be_able_to :update, copyrighted_video }
    end
  end

  describe '#page_url' do
    subject { video.page_url }
    let(:anime) { build_stubbed(:anime, id: 2001) }
    let(:video) { build_stubbed(:anime_video, id: 76543, episode: 14, anime: anime) }

    it { is_expected.to eq 'play.shikimori.org/animes/2001/video_online/14/76543' }
  end
end
