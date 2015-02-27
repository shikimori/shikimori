require 'cancan/matchers'

describe AnimeVideo do
  describe 'relations' do
    it { should belong_to :anime }
    it { should belong_to :author }
    it { should have_many(:reports).dependent :destroy }
  end

  describe 'validations' do
    it { should validate_presence_of :anime }
    it { should validate_presence_of :url }
    it { should validate_presence_of :source }
    it { should validate_presence_of :kind }
    it { should validate_numericality_of(:episode).is_greater_than_or_equal_to(0) }
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
          it { should have(states.size).items }
        end

        context 'bad states' do
          let(:states) { ['broken', 'wrong', 'banned', 'copyrighted' ] }
          it { should be_empty }
        end
      end
    end

    describe '#allowed_play' do
      subject { AnimeVideo.allowed_play }

      context 'true' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: false) }
          it { should have(1).item }
        end

        context 'by_reting' do
          before { create :anime_video, anime: create(:anime, rating: 'None') }
          it { should have(1).item }
        end
      end

      context 'false' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: true) }
          it { should be_blank }
        end

        context 'by_rating' do
          before do
            Anime::ADULT_RATINGS.each { |rating|
              create :anime_video, anime: create(:anime, rating: rating)
            }
          end

          it { should be_blank }
        end
      end
    end

    describe '#allowed_xplay' do
      subject { AnimeVideo.allowed_xplay }

      context 'false' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: false) }
          it { should be_blank }
        end

        context 'by_reting' do
          before { create :anime_video, anime: create(:anime, rating: 'None') }
          it { should be_blank }
        end
      end

      context 'true' do
        context 'by_censored' do
          before { create :anime_video, anime: create(:anime, censored: true) }
          it { should have(1).item }
        end

        context 'by_rating' do
          before { create :anime_video, anime: create(:anime, rating: Anime::ADULT_RATINGS.first) }
          it { should have(1).item }
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
          it { should be_truthy }
        end

        context 'no_ban' do
          let(:url) { 'http://vk.com/j8n3/' }
          it { should be_falsy }
        end
      end

      describe '#copyrighted' do
        let(:anime_video) { build :anime_video, anime: create(:anime, id: anime_id) }
        subject { anime_video.copyrighted? }

        context 'ban' do
          let(:anime_id) { AnimeVideo::CopyrightBanAnimeIDs.first }
          it { should be_truthy }
        end

        context 'not_ban' do
          let(:anime_id) { 1 }
          it { should be_falsy }
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

          its(:is_raw) { should be_truthy }
          its(:is_subtitles) { should be_nil }
          its(:is_fandub) { should be_nil }
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

          its(:is_raw) { should be_truthy }
          its(:is_subtitles) { should be_truthy }
          its(:is_fandub) { should be_nil }
          it { expect(EpisodeNotification.all).to have(1).item }
        end

        context 'not_new_episode' do
          let!(:anime_video_1) { create :anime_video, :with_notification, anime: anime, url: url_1 }
          let!(:anime_video_2) { create :anime_video, :with_notification, anime: anime, url: url_2 }
          it { expect(EpisodeNotification.all).to have(1).item }
        end

        context 'not need notification if video kind is unknown' do
          let!(:anime_video_1) { create :anime_video, :with_notification, anime: anime, url: url_1, kind: :unknown }
          it { expect(EpisodeNotification.all).to be_empty }
        end
      end
    end
  end

  describe 'state_machine' do
    subject(:video) { create :anime_video }

    context 'initial' do
      it { should be_working }
    end

    context 'broken' do
      before { video.broken }
      it { should be_broken }
    end

    context 'wrong' do
      before { video.wrong }
      it { should be_wrong }
    end

    context 'ban' do
      before { video.ban }
      it { should be_banned }
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
    describe '#hosting' do
      subject { build(:anime_video, url: url).hosting }

      context 'valid_url' do
        let(:url) { 'http://vk.com/video_ext.php?oid=1' }
        it { should eq 'vk.com' }
      end

      context 'remove_www' do
        let(:url) { 'http://www.vk.com?id=1' }
        it { should eq 'vk.com' }
      end

      context 'second_level_domain' do
        let(:url) { 'http://www.foo.bar.com/video?id=1' }
        it { should eq 'bar.com' }
      end

      context 'alias_vk_com' do
        let(:url) { 'http://vkontakte.ru/video?id=1' }
        it { should eq 'vk.com' }
      end
    end

    describe '#vk?' do
      subject { video.vk? }
      let(:video) { build :anime_video, url: url }

      context 'true' do
        let(:url) { 'http://www.vk.com?id=1' }
        it { should be_truthy }
      end

      context 'false' do
        let(:url) { 'http://www.foo.bar.com/video?id=1' }
        it { should be_falsy }
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
        it { should be_truthy }
      end

      context 'not_ban' do
        let(:anime_id) { 1 }
        it { should be_falsy }
      end
    end

    describe '#mobile_compatible?' do
      let(:anime_video) { build :anime_video, url: url }
      subject { anime_video.mobile_compatible? }

      context 'true' do
        context 'vk_com' do
          let(:url) { 'http://vk.com?video=1' }
          it { should be_truthy }
        end

        context 'vkontakte_com' do
          let(:url) { 'http://vkontakte.ru?video=1' }
          it { should be_truthy }
        end
      end
      context 'false' do
        let(:url) { 'http://rutube.ru?video=1' }
        it { should be_falsy }
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

        it { should eq user }
      end

      context 'without_uploader' do
        context 'working' do
          let(:state) { 'working' }
          it { should be_nil }
        end

        context 'uploaded_without_report' do
          let(:state) { 'uploaded' }
          it { should be_nil }
        end
      end
    end

    describe '#author_name' do
      subject(:anime_video) { build_stubbed :anime_video, author: author }

      context 'no author' do
        let(:author) { }
        its(:author_name) { should be_nil }
      end

      context 'with author' do
        let(:author) { build_stubbed :anime_video_author }
        its(:author_name) { should eq author.name }
      end
    end

    describe '#author_name=' do
      subject(:anime_video) { build_stubbed :anime_video }
      let!(:author) { }
      let(:author_name) { 'fofofo' }
      before { anime_video.author_name = author_name }

      context 'new author' do
        its(:author_name) { should eq author_name }
      end

      context 'present author' do
        let(:author) { create :anime_video_author, name: author_name }
        its(:author) { should eq author }
      end
    end

    describe '#moderated_update' do
      let(:video) { create :anime_video, episode: 1 }
      let(:params) { {episode: 2} }

      context 'without_current_user' do
        let(:moderated_update) { video.moderated_update params }

        it { expect(moderated_update).to be_truthy }
        it { moderated_update; expect(video.reload.episode).to eq 2 }

        context 'check_versions' do
          before { moderated_update }
          subject { Version.last }
          let(:diff_hash) {{ episode: [1,2] }}

          it { should_not be_nil }
          its(:item_id) { should eq video.id }
          its(:item_diff) { should eq diff_hash.to_s }
          its(:item_type) { should eq video.class.name }
        end
      end

      context 'with_current_user' do
        let(:current_user) { create :user, :user }
        let(:moderated_update) { video.moderated_update params, current_user }
        before { moderated_update }
        subject { Version.last }

        its(:user_id) { should eq current_user.id }
      end
    end

    describe '#versions' do
      let(:video) { create :anime_video, episode: 1 }
      let(:update_params_1) { {episode: 2} }
      let(:update_params_2) { {episode: 3} }
      let(:last_diff_hash) { {episode: [2,3]} }
      before do
        video.moderated_update update_params_1
        video.moderated_update update_params_2
      end

      subject { video.reload.versions }
      it { should_not be_blank }
      it { should have(2).items }
      it { expect(subject.last.item_diff).to eq last_diff_hash.to_s }
    end
  end

  describe 'permissions' do
    subject { Ability.new user }
    let(:uploaded_video) { build :anime_video, state: 'uploaded' }
    let(:working_video) { build :anime_video, state: 'working' }
    let(:broken_video) { build :anime_video, state: 'broken' }

    describe 'guest' do
      let(:user) { }
      it { should be_able_to :new, uploaded_video }
      it { should be_able_to :create, uploaded_video }
      it { should_not be_able_to :new, working_video }
      it { should_not be_able_to :create, working_video }
      it { should_not be_able_to :new, broken_video }
      it { should_not be_able_to :create, broken_video }

      it { should_not be_able_to :edit, uploaded_video }
      it { should_not be_able_to :update, uploaded_video }
      it { should_not be_able_to :edit, working_video }
      it { should_not be_able_to :update, working_video }
    end

    describe 'user' do
      let(:user) { build_stubbed :user, :user }
      it { should be_able_to :new, uploaded_video }
      it { should be_able_to :create, uploaded_video }
      it { should_not be_able_to :new, working_video }
      it { should_not be_able_to :create, working_video }
      it { should_not be_able_to :new, broken_video }
      it { should_not be_able_to :create, broken_video }

      it { should be_able_to :edit, uploaded_video }
      it { should be_able_to :update, uploaded_video }
      it { should be_able_to :edit, working_video }
      it { should be_able_to :update, working_video }
    end
  end
end
