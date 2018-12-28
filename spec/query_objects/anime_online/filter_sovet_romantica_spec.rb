describe AnimeOnline::FilterSovetRomantica do
  let(:query) { AnimeOnline::FilterSovetRomantica.new videos }

  describe '#call' do
    subject! { query.call }

    context 'with videos' do
      let(:videos) { [video_1, video_2, video_3, video_4] }

      let(:video_1) do
        create :anime_video,
          author_name: 'SovetRomantica',
          url: 'https://smotretanime.ru/catalog/haikyuu-karasuno-koukou-vs-shiratorizawa-gakuen-koukou-14801/1-seriya-140162/russkie-subtitry-1013978',
          kind: :subtitles
      end
      let(:video_2) do
        create :anime_video,
          author_name: 'SovetRomantica (Bla Bla Bla)',
          url: 'https://smotretanime.ru/catalog/haikyuu-karasuno-koukou-vs-shiratorizawa-gakuen-koukou-14801/1-seriya-140162/angliyskie-subtitry-1014042',
          kind: :fandub
      end
      let(:video_3) do
        create :anime_video,
          author_name: 'SovetRomantica',
          url: 'https://sovetromantica.com/embed/episode_128_1-subtitles',
          kind: :fandub
      end
      let(:video_4) do
        create :anime_video,
          author_name: 'SovetRomantica',
          url: 'https://smotretanime.ru/catalog/haikyuu-karasuno-koukou-vs-shiratorizawa-gakuen-koukou-14801/1-seriya-140162/angliyskie-subtitry-1014041',
          kind: :unknown
      end

      it { is_expected.to eq [video_1, video_3, video_4] }
    end

    context 'broken original' do
      let(:videos) { [video_1, video_2] }
      let(:video_1) do
        create :anime_video,
          author_name: 'SovetRomantica (Bla Bla Bla)',
          url: 'https://smotretanime.ru/catalog/haikyuu-karasuno-koukou-vs-shiratorizawa-gakuen-koukou-14801/1-seriya-140162/angliyskie-subtitry-1014042',
          kind: :fandub
      end
      let(:video_2) do
        create :anime_video, :broken,
          author_name: 'SovetRomantica',
          url: 'https://sovetromantica.com/embed/episode_128_1-subtitles',
          kind: :fandub
      end
      it { is_expected.to eq [video_1, video_2] }
    end

    context 'broken original and working original' do
      let(:videos) { [video_1, video_2, video_3] }
      let(:video_1) do
        create :anime_video,
          author_name: 'SovetRomantica (Bla Bla Bla)',
          url: 'https://smotretanime.ru/catalog/haikyuu-karasuno-koukou-vs-shiratorizawa-gakuen-koukou-14801/1-seriya-140162/angliyskie-subtitry-1014042',
          kind: :fandub
      end
      let(:video_2) do
        create :anime_video, :broken,
          author_name: 'SovetRomantica',
          url: 'https://sovetromantica.com/embed/episode_128_1-subtitles',
          kind: :fandub
      end
      let(:video_3) do
        create :anime_video,
          author_name: 'SovetRomantica',
          url: 'https://sovetromantica.com/embed/episode_128_2-subtitles',
          kind: :fandub
      end
      it { is_expected.to eq [video_2, video_3] }
    end

    context 'no videos' do
      let(:videos) { nil }
      it { is_expected.to eq nil }
    end
  end
end
