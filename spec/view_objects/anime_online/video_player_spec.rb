describe AnimeOnline::VideoPlayer do
  let(:decorator) { AnimeOnline::VideoPlayer.new anime }

  #describe 'description' do
    #let(:anime) { build :anime, description: 'test' }
    #subject { decorator.description }

    #context 'first_episode' do
      #it { should eq BbCodeFormatter.instance.format_description('test', anime) }
    #end

    #context 'second_episode' do
      #before { allow_any_instance_of(AnimeOnline::VideoPlayer).to receive(:current_episode).and_return 2 }
      #it { should eq BbCodeFormatter.instance.format_description('test', anime) }
    #end
  #end

  #describe '#watch_increment_delay' do
    #let(:anime) { build :anime, duration: duration }
    #subject { decorator.watch_increment_delay }

    #context 'with_duration' do
      #let(:duration) { 2 }
      #it { should eq anime.duration * 60000 / 3 }
    #end

    #context 'without_duration' do
      #let(:duration) { 0 }
      #it { should be_nil }
    #end
  #end

  describe 'videos' do
    subject { decorator.videos }
    let(:anime) { create :anime }
    let(:episode) { 1 }

    context 'anime_without_videos' do
      it { should be_blank }
    end

    context 'anime_with_one_video' do
      let!(:video) { create :anime_video, episode: episode, anime: anime }
      it { should eq episode => [video] }
    end

    context 'anime_with_two_videos' do
      let!(:video_1) { create :anime_video, episode: episode, anime: anime }
      let!(:video_2) { create :anime_video, episode: episode, anime: anime }
      it { should eq episode => [video_1, video_2] }
    end

    context 'no_working' do
      let!(:video_1) { create :anime_video, episode: episode, state: :broken }
      it { should be_empty }
    end

    context 'only working' do
      let!(:video_1) { create :anime_video, episode: episode, state: 'working', anime: anime }
      let!(:video_2) { create :anime_video, episode: episode, state: 'broken', anime: anime }
      let!(:video_3) { create :anime_video, episode: episode, state: 'wrong', anime: anime }
      it { should eq episode => [video_1] }
    end
  end

  describe '#episode_videos' do
    subject { AnimeOnline::VideoPlayer.new(anime).episode_videos }
    let(:anime) { create :anime }

    context 'without vidoes' do
      it { should be_blank }
    end

    context 'vk first' do
      let!(:video_vk) { create :anime_video, url: 'http://vk.com/video', anime: anime }
      let!(:video_other) { create :anime_video, url: 'http://aaa.com/video', anime: anime }

      its(:first) { should eq video_vk }
    end

    context 'fandub first' do
      let!(:video_fandub) { create :anime_video, kind: :fandub, anime: anime }
      let!(:video_sublitles) { create :anime_video, kind: :subtitles, anime: anime }

      its(:first) { should eq video_fandub }
    end

    context 'unknown as fandub first' do
      let!(:video_unknown) { create :anime_video, kind: :unknown, anime: anime }
      let!(:video_sublitles) { create :anime_video, kind: :subtitles, anime: anime }

      its(:first) { should eq video_unknown }
    end
  end

  describe '#try_select_by' do
    subject { AnimeOnline::VideoPlayer.new(anime).send :try_select_by, kind.to_s, hosting, author_id }
    let(:anime) { create :anime }

    context 'author_nil' do
      let(:kind) { :fandub }
      let(:hosting) { 'vk.com' }
      let(:author_id) { 1 }
      let!(:video) { create :anime_video, kind: kind, url: 'http://vk.com', author: nil, anime: anime }
      it { should eq video }
    end
  end

  describe 'last_episode' do
    subject { AnimeOnline::VideoPlayer.new(anime).last_episode }
    let(:anime) { create :anime }

    context 'without_video' do
      it { should be_nil }
    end

    context 'with_video' do
      let!(:video_1) { create :anime_video, episode: 1, anime: anime }
      let!(:video_2) { create :anime_video, episode: 2, anime: anime }
      it { should eq 2 }
    end
  end

  #describe 'current_author' do
    #subject { AnimeOnline::VideoPlayer.new(anime).current_author }
    #let(:anime) { build :anime }
    #before { allow_any_instance_of(AnimeOnline::VideoPlayer).to receive(:current_video).and_return video }

    #context 'current_video_nil' do
      #let(:video) { nil }
      #it { should be_blank }
    #end

    #context 'author_nil' do
      #let(:video) { build :anime_video, author: nil }
      #it { should be_blank }
    #end

    #context 'author_valid' do
      #let(:video) { build :anime_video, author: build(:anime_video_author, name: 'test') }
      #it { should eq 'test' }
    #end

    #context 'author_very_long' do
      #let(:video) { build :anime_video, author: build(:anime_video_author, name: 'test12345678901234567890') }
      #it { should eq 'test1234567890123...' }
    #end
  #end

  #describe 'last_date' do
    #subject { AnimeOnline::VideoPlayer.new(anime).last_date }
    #let(:last_date) { DateTime.now }

    #context 'with_video' do
      #let(:anime) { build :anime, anime_videos: [build(:anime_video, created_at: last_date)] }
      #it { should eq last_date }
    #end

    #context 'without_video' do
      #let(:anime) { build :anime, created_at: last_date }
      #it { should eq last_date }
    #end
  #end
end
