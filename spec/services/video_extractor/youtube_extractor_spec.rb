describe VideoExtractor::YoutubeExtractor do
  let(:service) { described_class.instance }

  describe '#fetch' do
    subject { service.fetch url }

    context 'valid_url' do
      context 'common case' do
        let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/VdwKZ6JDENc/hqdefault.jpg',
            player_url: '//youtube.com/embed/VdwKZ6JDENc'
          )
        end
      end

      context 'youtu.be' do
        let(:url) { 'http://youtu.be/n5qqfOXRRaA?t=3m3s' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/n5qqfOXRRaA/hqdefault.jpg',
            player_url: '//youtube.com/embed/n5qqfOXRRaA?start=3m3s'
          )
        end
      end

      context 'embed url' do
        let(:url) { 'https://www.youtube.com/embed/paezRkeNr5Q?start=3m3s' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/paezRkeNr5Q/hqdefault.jpg',
            player_url: '//youtube.com/embed/paezRkeNr5Q?start=3m3s'
          )
        end
      end

      context 'www.youtube.com/v/' do
        let(:url) { '//www.youtube.com/embed/paezRkeNr5Q?start=5s' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/paezRkeNr5Q/hqdefault.jpg',
            player_url: '//youtube.com/embed/paezRkeNr5Q?start=5s'
          )
        end
      end

      context 'with time' do
        let(:url) do
          [
            'http://www.youtube.com/watch?v=VdwKZ6JDENc#t=123',
            'http://www.youtube.com/watch?v=VdwKZ6JDENc#at=123'
          ].sample
        end

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/VdwKZ6JDENc/hqdefault.jpg',
            player_url: '//youtube.com/embed/VdwKZ6JDENc?start=123'
          )
        end
      end

      context '& params after' do
        let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc&ff=vcxvcx' }
        it do
          is_expected.to have_attributes(
            player_url: '//youtube.com/embed/VdwKZ6JDENc'
          )
        end
      end

      context '&amp; params after' do
        let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc&amp;ff=vcxvcx' }
        it do
          is_expected.to have_attributes(
            player_url: '//youtube.com/embed/VdwKZ6JDENc'
          )
        end
      end

      context '& params before' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc' }
        it do
          is_expected.to have_attributes(
            player_url: '//youtube.com/embed/VdwKZ6JDENc'
          )
        end
      end

      context '&amp; params before' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&amp;v=VdwKZ6JDENc' }
        it do
          is_expected.to have_attributes(
            player_url: '//youtube.com/embed/VdwKZ6JDENc'
          )
        end
      end

      context 'params_surrounded' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc&ff=vcxvcx#t=123' }

        it do
          is_expected.to have_attributes(
            player_url: '//youtube.com/embed/VdwKZ6JDENc?start=123'
          )
        end
      end
    end

    context 'invalid url' do
      context 'sample' do
        let(:url) { 'https//youtube.com/ //?v=_' }
        it { is_expected.to be_nil }
      end

      context 'sample' do
        let(:url) { 'http://vk.com/video98023184_165811692zzz' }
        it { is_expected.to be_nil }
      end
    end
  end

  # describe '#exists?', vcr: { cassette_name: 'youtube_extractor' } do
  #   let(:url) { 'http://youtu.be/m-QoYo1gpPs' }
  #   it { expect(service).to be_exists }
  # end
end
