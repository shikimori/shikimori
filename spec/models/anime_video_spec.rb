describe AnimeVideo do
  describe 'relations' do
    it { is_expected.to belong_to :anime }
    it { is_expected.to belong_to(:author).optional }
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
          let(:states) { %w[working uploaded] }
          it { is_expected.to have(states.size).items }
        end

        context 'bad states' do
          let(:states) { %w[broken wrong banned_hosting copyrighted] }
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
      describe '#check_copyrighted_authors' do
        let(:anime_video) { build :anime_video, author_name: author_name }
        subject! { anime_video.save }

        # context 'copyrighted' do
        #   # let(:author_name) { %w[wakanim crunchyroll].sample }
        #   let(:author_name) { 'wakanim' }
        #   it do
        #     is_expected.to eq false
        #     expect(anime_video.errors[:base]).to eq [
        #       'Видео этого автора не могут быть загружены на сайт'
        #     ]
        #   end
        # end

        context 'not copyrighted' do
          let(:author_name) { 'zzz' }
          it do
            is_expected.to eq true
            expect(anime_video.errors).to be_empty
          end
        end
      end

      describe '#check_banned_hostings' do
        subject(:anime_video) { create :anime_video, url: url }

        context 'banned hosting' do
          let(:url) { 'http://v.kiwi.kz/v2/9l7tsj8n3has/' }
          it { is_expected.to be_banned_hosting }
        end

        context 'not banned hosting' do
          let(:url) { attributes_for(:anime_video)[:url] }
          it { is_expected.to_not be_banned_hosting }
        end
      end

      describe '#check_copyrighted_animes' do
        subject(:anime_video) { create :anime_video, anime: anime }
        let(:anime) { create :anime, id: anime_id }

        context 'banned anime_id' do
          let(:anime_id) { AnimeVideo::COPYRIGHT_BAN_ANIME_IDS.first }
          it { is_expected.to be_copyrighted }
        end

        context 'not banned anime_id' do
          let(:anime_id) { 1 }
          it { is_expected.to_not be_copyrighted }
        end
      end
    end

    describe 'after_create' do
      describe '#create_episode_notification' do
        let!(:another_video) { nil }
        before { allow(EpisodeNotification::Create).to receive :call }
        let!(:video) do
          create :anime_video, :with_episode_notification, :fandub,
            anime: anime
        end
        let(:anime) { build_stubbed :anime }

        context 'single video' do
          context 'not anons' do
            it do
              expect(EpisodeNotification::Create)
                .to have_received(:call)
                .with(
                  anime_id: video.anime_id,
                  episode: video.episode,
                  kind: video.kind
                )
            end
          end

          context 'anons' do
            let(:anime) { build_stubbed :anime, :anons }
            it { expect(EpisodeNotification::Create).to_not have_received :call }
          end
        end

        context 'not single video' do
          let!(:another_video) do
            create :anime_video,
              anime: video.anime,
              episode: video.episode,
              kind: video.kind
          end
          it { expect(EpisodeNotification::Create).to_not have_received(:call) }
        end
      end
    end

    describe 'after_update' do
      describe '#create_episode_notification & #rollback_episode_notification' do
        let(:anime_1) { create :anime }
        let(:anime_2) { create :anime }

        let(:changes) do
          [{
            old: {
              episode: 2,
              kind: 'fandub',
              anime_id: anime_1.id
            },
            new: {
              episode: 3,
              kind: 'fandub',
              anime_id: anime_1.id
            }
          }, {
            old: {
              episode: 2,
              kind: 'fandub',
              anime_id: anime_1.id
            },
            new: {
              episode: 2,
              kind: 'subtitles',
              anime_id: anime_1.id
            }
          }, {
            old: {
              episode: 2,
              kind: 'fandub',
              anime_id: anime_1.id
            },
            new: {
              episode: 2,
              kind: 'fandub',
              anime_id: anime_2.id
            }
          }].sample
        end

        let!(:video) do
          create :anime_video, :with_episode_notification, changes[:old]
        end
        let!(:another_video) { nil }

        before { allow(EpisodeNotification::Create).to receive :call }
        before { allow(EpisodeNotification::Rollback).to receive :call }

        subject! { video.update! changes[:new] }

        context 'single video' do
          it do
            expect(EpisodeNotification::Create)
              .to have_received(:call)
              .with(changes[:new])
            expect(EpisodeNotification::Rollback)
              .to have_received(:call)
              .with(changes[:old])
          end
        end

        context 'not single new_episode video' do
          let!(:another_video) { create :anime_video, changes[:new] }
          it do
            expect(EpisodeNotification::Create).to_not have_received(:call)
            expect(EpisodeNotification::Rollback)
              .to have_received(:call)
              .with(changes[:old])
          end
        end

        context 'not single old_episode video' do
          let!(:another_video) { create :anime_video, changes[:old] }
          it do
            expect(EpisodeNotification::Create)
              .to have_received(:call)
              .with(changes[:new])
            expect(EpisodeNotification::Rollback).to_not have_received(:call)
          end
        end
      end
    end

    describe 'after_destroy' do
      describe '#rollback_episode_notification' do
        let!(:another_video) { nil }
        let!(:video) { create :anime_video, :with_episode_notification, :fandub }
        before { allow(EpisodeNotification::Rollback).to receive :call }

        subject! { video.destroy }

        context 'single video' do
          it do
            expect(EpisodeNotification::Rollback)
              .to have_received(:call)
              .with(
                anime_id: video.anime_id,
                episode: video.episode,
                kind: video.kind
              )
          end
        end

        context 'not single video' do
          let!(:another_video) do
            create :anime_video,
              anime: video.anime,
              episode: video.episode,
              kind: video.kind
          end
          it { expect(EpisodeNotification::Rollback).to_not have_received(:call) }
        end
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
      it { is_expected.to be_banned_hosting }
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

    describe '#rollback_episode_notification' do
      before { allow(EpisodeNotification::Rollback).to receive :call }

      let!(:video) { create :anime_video, :with_episode_notification, :fandub }
      let!(:another_video) { nil }
      subject! { video.send 'broken' }

      context 'single video' do
        it do
          expect(EpisodeNotification::Rollback)
            .to have_received(:call)
            .with(
              anime_id: video.anime_id,
              episode: video.episode,
              kind: video.kind
            )
        end
      end

      context 'not single video' do
        let!(:another_video) do
          create :anime_video,
            anime: video.anime,
            episode: video.episode,
            kind: video.kind
        end
        it { expect(EpisodeNotification::Rollback).to_not have_received(:call) }
      end
    end

    describe '#process_reports' do
      %i[broken wrong ban].each do |action|
        context action do
          let(:video) { create :anime_video }
          let!(:pending_upload_report) { create :anime_video_report, :uploaded, :accepted, anime_video: video }
          let!(:uploaded_upload_report) { create :anime_video_report, :uploaded, :accepted, anime_video: video }
          let!(:wrong_report) { create :anime_video_report, :wrong, :pending, anime_video: video }
          let!(:broken_report) { create :anime_video_report, :broken, :pending, anime_video: video }
          let!(:other_report) { create :anime_video_report, :other, :pending, anime_video: video }

          before { video.send action }
          it do
            expect(pending_upload_report.reload).to be_post_rejected
            expect(uploaded_upload_report.reload).to be_post_rejected
            expect(wrong_report.reload).to be_accepted
            expect(broken_report.reload).to be_accepted
            expect(other_report.reload).to be_accepted
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
          it { expect(video.url).to eq 'http://vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16' }
        end

        context 'url w/o http' do
          let(:url) { 'vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16' }
          it { expect(video.url).to eq "http://#{url}" }
        end
      end

      describe 'persisted video', :vcr do
        let(:video) { build_stubbed :anime_video, url: url }
        let(:url) { 'http://rutube.ru/video/ef370e68cd9687a30ea67a68658c6ef8/?ref=logo' }
        before { video.url = new_url }

        describe 'indirect url' do
          let(:new_url) { '<iframe width="720" height="405" src="//rutube.ru/play/embed/3599097" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>' }
          it { expect(video.url).to eq 'http://rutube.ru/play/embed/ef370e68cd9687a30ea67a68658c6ef8' }
        end

        describe 'direct url' do
          let(:new_url) { 'http://rutube.ru/play/embed/3599097' }
          it { expect(video.url).to eq 'http://rutube.ru/play/embed/ef370e68cd9687a30ea67a68658c6ef8' }
        end
      end
    end

    describe '#hosting' do
      let(:anime_video) { build :anime_video }
      before { anime_video[:url] = url }
      subject! { anime_video.hosting }

      let(:url) { 'http://www.vk.com?id=1' }
      it { is_expected.to eq 'vk.com' }
    end

    describe '#vk?, #smotret_anime?' do
      let(:video) { build :anime_video, url: url }

      context 'vk' do
        let(:url) { attributes_for(:anime_video)[:url] }
        it { expect(video).to be_vk }
        it { expect(video).to_not be_smotret_anime }
      end

      context 'smotret_anime' do
        let(:url) { 'http://smotretanime.ru/translations/embed/960633' }
        it { expect(video).to_not be_vk }
        it { expect(video).to be_smotret_anime }
      end
    end

    describe '#allowed?' do
      context 'true' do
        %w[working uploaded].each do |state|
          it { expect(build(:anime_video, state: state).allowed?).to eq true }
        end
      end

      context 'false' do
        %w[broken wrong banned_hosting].each do |state|
          it { expect(build(:anime_video, state: state).allowed?).to eq false }
        end
      end
    end

    describe '#copyright_ban' do
      before { stub_const('AnimeVideo::COPYRIGHT_BAN_ANIME_IDS', [2]) }
      let(:anime_video) { build :anime_video, anime_id: anime_id }
      subject { anime_video.copyright_ban? }

      context 'ban' do
        let(:anime_id) { AnimeVideo::COPYRIGHT_BAN_ANIME_IDS.first }
        it { is_expected.to eq true }
      end

      context 'not_ban' do
        let(:anime_id) { 1 }
        it { is_expected.to eq false }
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
        let(:author) {}
        its(:author_name) { is_expected.to be_nil }
      end

      context 'with author' do
        let(:author) { build_stubbed :anime_video_author }
        its(:author_name) { is_expected.to eq author.name }
      end
    end

    describe '#author_name=' do
      subject(:anime_video) { build_stubbed :anime_video }
      let!(:author) {}
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
    let(:banned_video) { build :anime_video, state: 'banned_hosting' }
    let(:copyrighted_video) { build :anime_video, state: 'copyrighted' }

    describe 'guest' do
      let(:user) {}
      it { is_expected.to_not be_able_to :new, uploaded_video }
      it { is_expected.to_not be_able_to :create, uploaded_video }

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

      context 'day_registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }

        it { is_expected.to be_able_to :new, uploaded_video }
        it { is_expected.to be_able_to :create, uploaded_video }
      end

      context 'not day_registered' do
        it { is_expected.to_not be_able_to :new, uploaded_video }
        it { is_expected.to_not be_able_to :create, uploaded_video }
      end

      it { is_expected.to_not be_able_to :new, working_video }
      it { is_expected.to_not be_able_to :create, working_video }
      it { is_expected.to_not be_able_to :new, broken_video }
      it { is_expected.to_not be_able_to :create, broken_video }

      it { is_expected.to_not be_able_to :destroy, uploaded_video }

      context 'day_registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }

        it { is_expected.to be_able_to :edit, uploaded_video }
        it { is_expected.to be_able_to :update, uploaded_video }
        it { is_expected.to be_able_to :edit, working_video }
        it { is_expected.to be_able_to :update, working_video }
      end

      context 'not day_registered' do
        it { is_expected.to_not be_able_to :edit, uploaded_video }
        it { is_expected.to_not be_able_to :update, uploaded_video }
        it { is_expected.to_not be_able_to :edit, working_video }
        it { is_expected.to_not be_able_to :update, working_video }
      end

      it { is_expected.to_not be_able_to :edit, banned_video }
      it { is_expected.to_not be_able_to :update, banned_video }
      it { is_expected.to_not be_able_to :edit, copyrighted_video }
      it { is_expected.to_not be_able_to :update, copyrighted_video }
    end

    describe 'not_trusted_video_uploader' do
      let(:user) { build_stubbed :user, :not_trusted_video_uploader }

      it { is_expected.to_not be_able_to :new, uploaded_video }
      it { is_expected.to_not be_able_to :create, uploaded_video }
      it { is_expected.to_not be_able_to :edit, uploaded_video }
      it { is_expected.to_not be_able_to :update, uploaded_video }
      it { is_expected.to_not be_able_to :edit, working_video }
      it { is_expected.to_not be_able_to :update, working_video }
    end

    describe 'video uploader' do
      let(:user) { create :user, :user, :day_registered }

      let(:video) do
        build_stubbed :anime_video,
          created_at: created_at,
          state: 'uploaded'
      end
      let!(:upload_report) do
        create :anime_video_report,
          anime_video: video,
          user: user,
          kind: 'uploaded'
      end

      context 'video created long ago' do
        let(:created_at) { 1.week.ago - 1.day }

        context 'api video uploader' do
          let(:user) { create :user, :api_video_uploader, :day_registered }
          it { is_expected.to be_able_to :destroy, video }
        end

        context 'not api video uploader' do
          it { is_expected.to_not be_able_to :destroy, video }
        end
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
      it { is_expected.to_not be_able_to :destroy, uploaded_video }

      it { is_expected.to be_able_to :edit, uploaded_video }
      it { is_expected.to be_able_to :update, uploaded_video }
      it { is_expected.to be_able_to :edit, working_video }
      it { is_expected.to be_able_to :update, working_video }
      it { is_expected.to_not be_able_to :destroy, working_video }
      it { is_expected.to be_able_to :edit, broken_video }
      it { is_expected.to be_able_to :update, broken_video }
      it { is_expected.to_not be_able_to :destroy, broken_video }

      it { is_expected.to_not be_able_to :edit, banned_video }
      it { is_expected.to_not be_able_to :update, banned_video }
      it { is_expected.to_not be_able_to :destroy, banned_video }
      it { is_expected.to_not be_able_to :edit, copyrighted_video }
      it { is_expected.to_not be_able_to :update, copyrighted_video }
      it { is_expected.to_not be_able_to :destroy, copyrighted_video }
    end
  end
end
