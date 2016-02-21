describe AnimeOnline::VideoPlayer do
  let(:player) { AnimeOnline::VideoPlayer.new anime }
  let(:anime) { build :anime }

  #describe '#watch_increment_delay' do
    #let(:anime) { build :anime, duration: duration }
    #subject { player.watch_increment_delay }

    #context 'with_duration' do
      #let(:duration) { 2 }
      #it { is_expected.to eq anime.duration * 60000 / 3 }
    #end

    #context 'without_duration' do
      #let(:duration) { 0 }
      #it { is_expected.to be_nil }
    #end
  #end

  describe 'videos' do
    subject { player.videos }
    let(:anime) { create :anime }
    let(:episode) { 1 }

    context 'anime_without_videos' do
      it { is_expected.to be_blank }
    end

    context 'anime_with_one_video' do
      let!(:video) { create :anime_video, episode: episode, anime: anime }
      it { is_expected.to eq episode => [video] }
    end

    context 'anime_with_two_videos' do
      let!(:video_1) { create :anime_video, episode: episode, anime: anime }
      let!(:video_2) { create :anime_video, episode: episode, anime: anime }
      it { is_expected.to eq episode => [video_1, video_2] }
    end

    context 'no_working' do
      let!(:video_1) { create :anime_video, episode: episode, state: :broken }
      it { is_expected.to be_empty }
    end

    context 'only working' do
      let!(:video_1) { create :anime_video, episode: episode, state: 'working', anime: anime }
      let!(:video_2) { create :anime_video, episode: episode, state: 'broken', anime: anime }
      let!(:video_3) { create :anime_video, episode: episode, state: 'wrong', anime: anime }
      it { is_expected.to eq episode => [video_1] }
    end
  end

  describe '#episode_videos' do
    subject { player.episode_videos }
    let(:anime) { create :anime }

    context 'without vidoes' do
      it { is_expected.to be_blank }
    end

    context 'vk first' do
      let!(:video_vk) { create :anime_video, url: 'http://vk.com/video', anime: anime }
      let!(:video_other) { create :anime_video, url: 'http://aaa.com/video', anime: anime }

      its(:first) { is_expected.to eq video_vk }
    end

    context 'fandub first' do
      let!(:video_fandub) { create :anime_video, kind: :fandub, anime: anime }
      let!(:video_sublitles) { create :anime_video, kind: :subtitles, anime: anime }

      its(:first) { is_expected.to eq video_fandub }
    end

    context 'unknown as fandub first' do
      let!(:video_unknown) { create :anime_video, kind: :unknown, anime: anime }
      let!(:video_sublitles) { create :anime_video, kind: :subtitles, anime: anime }

      its(:first) { is_expected.to eq video_unknown }
    end
  end

  describe '#same_videos' do
    let(:anime) { create :anime }

    let!(:video_vk_1) { create :anime_video, url: 'http://vk.com/video', anime: anime }
    let!(:video_vk_2) { create :anime_video, url: 'http://vk.com/video2', anime: anime }
    let!(:video_other) { create :anime_video, url: 'http://abc.com/video2', anime: anime }

    before { allow(player).to receive(:current_video).and_return video_vk_1.decorate }
    it { expect(player.same_videos).to have(2).items }
  end

  describe '#try_select_by' do
    subject { player.send :try_select_by, kind.to_s, hosting, author_id }
    let(:anime) { create :anime }

    context 'author_nil' do
      let(:kind) { :fandub }
      let(:hosting) { 'vk.com' }
      let(:author_id) { 1 }
      let!(:video) { create :anime_video, kind: kind, url: 'http://vk.com', author: nil, anime: anime }
      it { is_expected.to eq video }
    end
  end

  describe 'last_episode' do
    subject { player.last_episode }
    let(:anime) { create :anime }

    context 'without_video' do
      it { is_expected.to be_nil }
    end

    context 'with_video' do
      let!(:video_1) { create :anime_video, episode: 1, anime: anime }
      let!(:video_2) { create :anime_video, episode: 2, anime: anime }
      it { is_expected.to eq 2 }
    end
  end

  describe '#compatible?' do
    subject { player.compatible?(video) }
    let(:video) { build :anime_video, url: url }
    let(:url) { 'http://rutube.ru?video=1' }
    let(:h) { OpenStruct.new request: request, mobile?: is_mobile }
    let(:request) { OpenStruct.new user_agent: user_agent }
    let(:user_agent) { 'Mozilla/5.0 (Windows 2000; U) Opera 6.01 [en]' }
    before { allow(player).to receive(:h).and_return h }

    context 'desktop' do
      let(:is_mobile) { false }
      it { is_expected.to eq true }
    end

    context 'mobile' do
      let(:is_mobile) { true }

      context 'not vk' do
        it { is_expected.to eq false }
      end

      context 'vk' do
        let(:url) { 'http://vk.com?video=1' }
        it { is_expected.to eq true }
      end

      context 'android' do
        let(:user_agent) { 'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30' }

        context 'not vk' do
          it { is_expected.to eq true }
        end

        context 'vk' do
          let(:url) { 'http://vk.com?video=1' }
          it { is_expected.to eq true }
        end
      end
    end
  end

  #describe 'current_author' do
    #subject { player.current_author }
    #let(:anime) { build :anime }
    #before { allow_any_instance_of(AnimeOnline::VideoPlayer).to receive(:current_video).and_return video }

    #context 'current_video_nil' do
      #let(:video) { nil }
      #it { is_expected.to be_blank }
    #end

    #context 'author_nil' do
      #let(:video) { build :anime_video, author: nil }
      #it { is_expected.to be_blank }
    #end

    #context 'author_valid' do
      #let(:video) { build :anime_video, author: build(:anime_video_author, name: 'test') }
      #it { is_expected.to eq 'test' }
    #end

    #context 'author_very_long' do
      #let(:video) { build :anime_video, author: build(:anime_video_author, name: 'test12345678901234567890') }
      #it { is_expected.to eq 'test1234567890123...' }
    #end
  #end

  #describe 'last_date' do
    #subject { player.last_date }
    #let(:last_date) { DateTime.now }

    #context 'with_video' do
      #let(:anime) { build :anime, anime_videos: [build(:anime_video, created_at: last_date)] }
      #it { is_expected.to eq last_date }
    #end

    #context 'without_video' do
      #let(:anime) { build :anime, created_at: last_date }
      #it { is_expected.to eq last_date }
    #end
  #end
end
