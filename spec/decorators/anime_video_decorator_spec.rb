require 'spec_helper'

describe AnimeVideoDecorator do
  let(:decorator) { AnimeVideoDecorator.new anime }
  describe :description do
    let(:anime) { build :anime, description: 'test' }
    subject { decorator.description }

    context :first_episode do
      it { should eq BbCodeFormatter.instance.format_description('test', anime) }
    end

    context :second_episode do
      before { AnimeVideoDecorator.any_instance.stub(:current_episode).and_return 2 }
      it { should eq BbCodeFormatter.instance.format_description('test', anime) }
    end
  end

  describe '#watch_increment_delay' do
    let(:anime) { build :anime, duration: duration }
    subject { decorator.watch_increment_delay }

    context :with_duration do
      let(:duration) { 2 }
      it { should eq anime.duration * 60000 / 3 }
    end

    context :without_duration do
      let(:duration) { 0 }
      it { should be_nil }
    end
  end

  describe :videos do
    subject { decorator.videos }
    let(:anime) { build :anime }
    let(:episode) { 1 }

    context :anime_without_videos do
      it { should be_blank }
    end

    context :anime_with_one_video do
      let(:video) { build(:anime_video, episode: episode) }
      before { anime.anime_videos << video }
      it { should eq episode => [video] }
    end

    context :anime_with_two_videos do
      let(:video_1) { build(:anime_video, episode: episode) }
      let(:video_2) { build(:anime_video, episode: episode) }
      before { anime.anime_videos << [video_1, video_2] }
      it { should eq episode => [video_1, video_2] }
    end

    context :no_working do
      let(:video_1) { build(:anime_video, episode: episode, state: :broken) }
      before { anime.anime_videos << [video_1] }
      it { should be_empty }
    end

    context :only_working do
      let(:video_1) { build(:anime_video, episode: episode, state: 'working') }
      let(:video_2) { build(:anime_video, episode: episode, state: 'broken') }
      let(:video_3) { build(:anime_video, episode: episode, state: 'wrong') }
      before { anime.anime_videos << [video_1, video_2, video_3] }
      it { should eq episode => [video_1] }
    end
  end

  describe :dropdown_videos do
    subject { AnimeVideoDecorator.new(anime).dropdown_videos }
    let(:anime) { build :anime }

    context :without_vidoes do
      it { should be_blank }
    end

    context :vk_first do
      let(:video_vk) { build :anime_video, url: 'http://vk.com/video' }
      let(:video_other) { build :anime_video, url: 'http://aaa.com/video' }
      before { anime.anime_videos << [video_other, video_vk] }

      its(:first) { should eq video_vk }
    end

    context :fandub_first do
      let(:video_fandub) { build :anime_video, kind: :fandub }
      let(:video_sublitles) { build :anime_video, kind: :subtitles }
      before { anime.anime_videos << [video_sublitles, video_fandub] }

      its(:first) { should eq video_fandub }
    end

    context :unknown_as_fandub_first do
      let(:video_unknown) { build :anime_video, kind: :unknown }
      let(:video_sublitles) { build :anime_video, kind: :subtitles }
      before { anime.anime_videos << [video_sublitles, video_unknown] }

      its(:first) { should eq video_unknown }
    end
  end

  describe :try_select_by do
    subject { AnimeVideoDecorator.new(anime).try_select_by kind.to_s, hosting, author_id }
    before { AnimeVideoDecorator.any_instance.stub(:current_videos).and_return videos }
    let(:anime) { build :anime }

    context :author_nil do
      let(:kind) { :fandub }
      let(:hosting) { 'vk.com' }
      let(:author_id) { 1 }
      let(:videos) { [build(:anime_video, kind: kind, url: 'http://vk.com', author: nil)] }
      it { should eq videos.first }
    end
  end

  describe :last_episode do
    subject { AnimeVideoDecorator.new(anime).last_episode }
    let(:anime) { build :anime }
    context :without_video do
      it { should be_nil }
    end

    context :with_video do
      let(:video_1) { build :anime_video, episode: 1 }
      let(:video_2) { build :anime_video, episode: 2 }
      before { anime.anime_videos << [video_1, video_2] }
      it { should eq 2 }
    end
  end

  describe :current_author do
    subject { AnimeVideoDecorator.new(anime).current_author }
    let(:anime) { build :anime }
    before { AnimeVideoDecorator.any_instance.stub(:current_video).and_return video }

    context :current_video_nil do
      let(:video) { nil }
      it { should be_blank }
    end

    context :author_nil do
      let(:video) { build :anime_video, author: nil }
      it { should be_blank }
    end

    context :author_valid do
      let(:video) { build :anime_video, author: build(:anime_video_author, name: 'test') }
      it { should eq 'test' }
    end

    context :author_very_long do
      let(:video) { build :anime_video, author: build(:anime_video_author, name: 'test12345678901234567890') }
      it { should eq 'test1234567890123...' }
    end
  end

  describe :last_date do
    subject { AnimeVideoDecorator.new(anime).last_date }
    let(:last_date) { DateTime.now }

    context :with_video do
      let(:anime) { build :anime, anime_videos: [build(:anime_video, created_at: last_date)] }
      it { should eq last_date }
    end

    context :without_video do
      let(:anime) { build :anime, created_at: last_date }
      it { should eq last_date }
    end
  end
end
