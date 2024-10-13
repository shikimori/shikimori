describe VideoExtractor::YoutubeExtractor do
  let(:service) { described_class.instance }
  # rubocop:disable Lint/ConstantDefinitionInBlock
  FULL_URL_REGEX = /
    \A
      #{VideoExtractor::YoutubeExtractor::URL_REGEX.source}
    \Z
  /xi
  # rubocop:enable Lint/ConstantDefinitionInBlock

  describe '#fetch' do
    subject { service.fetch url }

    context 'valid_url' do
      context 'common case' do
        let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/VdwKZ6JDENc/hqdefault.jpg',
            player_url: '//youtube.com/embed/VdwKZ6JDENc',
            normalized_url: 'https://youtu.be/VdwKZ6JDENc'
          )
        end
        it { expect(url.match?(FULL_URL_REGEX)).to eq true }
      end

      context 'youtu.be' do
        let(:url) { 'http://youtu.be/n5qqfOXRRaA?t=3m3s' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/n5qqfOXRRaA/hqdefault.jpg',
            player_url: '//youtube.com/embed/n5qqfOXRRaA?start=3m3s',
            normalized_url: 'https://youtu.be/n5qqfOXRRaA'
          )
        end
        it { expect(url.match?(FULL_URL_REGEX)).to eq true }
      end

      context 'embed url' do
        let(:url) { 'https://www.youtube.com/embed/paezRkeNr5Q?start=3m3s' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/paezRkeNr5Q/hqdefault.jpg',
            player_url: '//youtube.com/embed/paezRkeNr5Q?start=3m3s',
            normalized_url: 'https://youtu.be/paezRkeNr5Q'
          )
        end
        it { expect(url.match?(FULL_URL_REGEX)).to eq true }
      end

      context 'www.youtube.com/v/' do
        let(:url) { '//www.youtube.com/embed/paezRkeNr5Q?start=5s' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube,
            image_url: '//img.youtube.com/vi/paezRkeNr5Q/hqdefault.jpg',
            player_url: '//youtube.com/embed/paezRkeNr5Q?start=5s',
            normalized_url: 'https://youtu.be/paezRkeNr5Q'
          )
        end
        it { expect(url.match?(FULL_URL_REGEX)).to eq true }
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
            player_url: '//youtube.com/embed/VdwKZ6JDENc?start=123',
            normalized_url: 'https://youtu.be/VdwKZ6JDENc'
          )
        end
        it { expect(url.match?(FULL_URL_REGEX)).to eq true }
      end

      context 'edge cases' do
        [
          'https://youtu.be/VdwKZ6JDENc?list=PLK7fGgm-avWC6KDk6rgH3LdKsar_oVdqR',
          'https://youtu.be/VdwKZ6JDENc?si=123',
          'https://youtu.be/VdwKZ6JDENc?zxc=123&vcb',
          'https://youtu.be/VdwKZ6JDENc?z-xc=123&vcb=df',
          'http://youtube.com/watch?v=VdwKZ6JDENc&ff=vcxvcx',
          'http://youtube.com/watch?v=VdwKZ6JDENc&amp;ff=vcxvcx',
          'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc',
          'http://youtube.com/watch?sdfdsf=dfdfs&amp;v=VdwKZ6JDENc'
        ].each do |sample|
          context sample do
            let(:url) { sample }
            it do
              is_expected.to have_attributes(
                player_url: '//youtube.com/embed/VdwKZ6JDENc'
              )
            end
            it { expect(url.match?(FULL_URL_REGEX)).to eq true }
          end
        end

        context 'with time' do
          [
            'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc&ff=vcxvcx#t=123',
            'https://youtu.be/VdwKZ6JDENc?zxc=1-23&t=123',
            'https://youtu.be/VdwKZ6JDENc?zxc=123&at=123',
            'https://youtu.be/VdwKZ6JDENc?t=123&zxc=123',
            'https://youtu.be/VdwKZ6JDENc?at=123&zxc=123'
          ].each do |sample|
            context sample do
              let(:url) { sample }
              it do
                is_expected.to have_attributes(
                  player_url: '//youtube.com/embed/VdwKZ6JDENc?start=123'
                )
              end
              it { expect(url.match?(FULL_URL_REGEX)).to eq true }
            end
          end
        end
      end

      context 'shorts' do
        let(:url) { 'https://youtube.com/shorts/yFg1-tIfvjc?si=6VLqJBX6zoeXrja2' }

        it do
          is_expected.to have_attributes(
            hosting: :youtube_shorts,
            image_url: '//img.youtube.com/vi/yFg1-tIfvjc/oardefault.jpg',
            player_url: '//youtube.com/embed/yFg1-tIfvjc',
            normalized_url: 'https://www.youtube.com/shorts/yFg1-tIfvjc'
          )
        end
        it { expect(url.match?(FULL_URL_REGEX)).to eq true }
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
