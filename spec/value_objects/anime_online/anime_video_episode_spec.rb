describe AnimeOnline::AnimeVideoEpisode do
  let(:anime_video_episode) do
    AnimeOnline::AnimeVideoEpisode.new(
      episode: episode,
      kinds: kinds,
      hostings: hostings
    )
  end
  let(:episode) { 1 }
  let(:kinds) { 'subtitles' }
  let(:hostings) { 'http://vk.com' }

  describe '#episode_text' do
    context 'zero episode' do
      let(:episode) { 0 }
      it { expect(anime_video_episode.episode_text).to eq '#прочее' }
    end

    context 'not zero episode' do
      let(:episode) { 1 }
      it { expect(anime_video_episode.episode_text).to eq '#1' }
    end
  end

  describe '#kinds, #kinds_text' do
    let(:kinds) { %w(subtitles fandub) }
    it { expect(anime_video_episode.kinds).to eq %i(fandub subtitles) }
    it { expect(anime_video_episode.kinds_text).to eq 'озвучка, субтитры' }
  end

  describe '#hostings, #hostings_text' do
    let(:hostings) { %w(http://video.sibnet.ru http://videoapi.my.mail.ru http://vk.com) }
    it { expect(anime_video_episode.hostings).to eq %i(vk sibnet mailru) }
    it { expect(anime_video_episode.hostings_text).to eq 'vk, sibnet, mailru' }
  end
end
