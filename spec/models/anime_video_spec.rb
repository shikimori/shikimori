describe AnimeVideo do
  describe 'relations' do
    it { is_expected.to belong_to :anime }
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

  describe 'callbacks' do
    describe 'before_save' do
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
  end
end
