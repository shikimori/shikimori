require 'spec_helper'

describe AnimeVideoDecorator do
  describe :description do
    let(:anime) { build :anime, description: 'test' }
    subject { AnimeVideoDecorator.new(anime).description }

    context :first_episode do
      it { should eq 'test' }
    end

    context :second_episode do
      before { AnimeVideoDecorator.any_instance.stub(:current_episode).and_return 2 }
      it { should be_nil }
    end
  end

  describe :current_episode do
    let(:anime) { build :anime }
    subject { AnimeVideoDecorator.new(anime).current_episode }
    before { AnimeVideoDecorator.any_instance.stub(:episode_id).and_return episode }

    context :episode_id_params_eq_zero do
      let(:episode) { 0 }
      it { should eq 1 }
    end

    context :episode_id_params_less_zero do
      let(:episode) { -1 }
      it { should eq 1 }
    end

    context :episode_id_params_2 do
      let(:episode) { 2 }
      it { should eq episode }
    end
  end

  describe :videos do
    subject { AnimeVideoDecorator.new(anime).videos }
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
end
