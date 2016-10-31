describe VideoExtractor::SovetRomanticaExtractor, :vcr do
  let(:service) { VideoExtractor::SovetRomanticaExtractor.new url }

  describe 'fetch' do
    subject! { service.fetch }
    let(:embed_url) { 'https://sovetromantica.com/embed/episode_116_12-subtitles' }

    let(:player_url) { '//sovetromantica.com/embed/episode_116_12-subtitles' }
    let(:image_url) { '//chitoge.sovetromantica.com/anime/116_91-days/images/episode_12_sub.jpg?1475282218' }

    context 'full url' do
      let(:url) { 'https://sovetromantica.com/anime/116-watashi-ga-motete-dousunda/episode_12-subtitles' }

      its(:hosting) { is_expected.to eq :sovet_romantica }
      its(:image_url) { is_expected.to eq image_url }
      its(:player_url) { is_expected.to eq player_url }
    end

    context 'embed url' do
      let(:url) { embed_url }

      its(:hosting) { is_expected.to eq :sovet_romantica }
      its(:image_url) { is_expected.to eq image_url }
      its(:player_url) { is_expected.to eq player_url }
    end
  end
end
