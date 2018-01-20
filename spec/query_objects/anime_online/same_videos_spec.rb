describe AnimeOnline::SameVideos do
  subject do
    described_class.call(
      anime_video_id: anime_video_1.id,
      anime_id: anime_video_1.anime_id,
      episode: anime_video_1.episode,
      kind: anime_video_1.kind
    )
  end

  let(:anime_1) { build_stubbed :anime }
  let(:anime_2) { build_stubbed :anime }

  let(:anime_video_1) { create :anime_video, :fandub, anime: anime_1 }
  let(:anime_video_2) { create :anime_video, :fandub, anime: anime_1 }
  let(:anime_video_3) { create :anime_video, :fandub, anime: anime_2 }
  let(:anime_video_4) { create :anime_video, :subtitles, anime: anime_1 }
  let(:anime_video_5) { create :anime_video, :fandub, :broken, anime: anime_1 }

  it { is_expected .to eq [anime_video_2] }
end
