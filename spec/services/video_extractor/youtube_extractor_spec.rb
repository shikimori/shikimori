describe VideoExtractor::YoutubeExtractor do
  let(:service) { described_class.new url }

  describe '#fetch' do
    subject { service.fetch }

    context 'valid_url' do
      context 'common case' do
        let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }

        its(:hosting) { is_expected.to eq :youtube }
        its(:image_url) { is_expected.to eq '//img.youtube.com/vi/VdwKZ6JDENc/hqdefault.jpg' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc' }
      end

      context 'youtu.be' do
        let(:url) { 'http://youtu.be/n5qqfOXRRaA?t=3m3s' }

        its(:hosting) { is_expected.to eq :youtube }
        its(:image_url) { is_expected.to eq '//img.youtube.com/vi/n5qqfOXRRaA/hqdefault.jpg' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/n5qqfOXRRaA?start=3m3s' }
      end

      context 'embed url' do
        let(:url) { 'https://www.youtube.com/embed/paezRkeNr5Q?start=3m3s' }

        its(:hosting) { is_expected.to eq :youtube }
        its(:image_url) { is_expected.to eq '//img.youtube.com/vi/paezRkeNr5Q/hqdefault.jpg' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/paezRkeNr5Q?start=3m3s' }
      end

      context 'www.youtube.com/v/' do
        let(:url) { '//www.youtube.com/embed/paezRkeNr5Q?start=5s' }

        its(:hosting) { is_expected.to eq :youtube }
        its(:image_url) { is_expected.to eq '//img.youtube.com/vi/paezRkeNr5Q/hqdefault.jpg' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/paezRkeNr5Q?start=5s' }
      end

      context 'with time' do
        let(:url) do
          [
            'http://www.youtube.com/watch?v=VdwKZ6JDENc#t=123',
            'http://www.youtube.com/watch?v=VdwKZ6JDENc#at=123'
          ].sample
        end

        its(:hosting) { is_expected.to eq :youtube }
        its(:image_url) { is_expected.to eq '//img.youtube.com/vi/VdwKZ6JDENc/hqdefault.jpg' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc?start=123' }
      end

      context '& params after' do
        let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc&ff=vcxvcx' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc' }
      end

      context '&amp; params after' do
        let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc&amp;ff=vcxvcx' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc' }
      end

      context '& params before' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc' }
        it { is_expected.to be_present }
      end

      context '&amp; params before' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&amp;v=VdwKZ6JDENc' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc' }
        it { is_expected.to be_present }
      end

      context 'params_surrounded' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc&ff=vcxvcx#t=123' }
        its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc?start=123' }
        it { is_expected.to be_present }
      end
    end

    context 'invalid url' do
      let(:url) { 'http://vk.com/video98023184_165811692zzz' }
      it { is_expected.to be_nil }
    end
  end

  # describe '#exists?', vcr: { cassette_name: 'youtube_extractor' } do
  #   let(:url) { 'http://youtu.be/m-QoYo1gpPs' }
  #   it { expect(service).to be_exists }
  # end
end
