describe ListImports::XmlStatus do
  let(:service) { ListImports::XmlStatus.new status, list_type, is_mal }
  let(:is_mal) { [true, false].sample }

  subject { service.call }

  context 'anime' do
    let(:list_type) { ::ListImports::ParseXml::ANIME_TYPE }

    context 'planned' do
      let(:status) { :planned }
      it { is_expected.to eq 'Plan to Watch' }
    end

    context 'watching' do
      let(:status) { :watching }
      it { is_expected.to eq 'Watching' }
    end

    context 'completed' do
      let(:status) { :completed }
      it { is_expected.to eq 'Completed' }
    end

    context 'on_hold' do
      let(:status) { :on_hold }
      it { is_expected.to eq 'On-Hold' }
    end

    context 'dropped' do
      let(:status) { :dropped }
      it { is_expected.to eq 'Dropped' }
    end

    context 'rewatching' do
      let(:status) { :rewatching }

      context 'mal' do
        let(:is_mal) { true }
        it { is_expected.to eq 'Completed' }
      end

      context 'not mal' do
        let(:is_mal) { false }
        it { is_expected.to eq 'Rewatching' }
      end
    end
  end

  context 'manga' do
    let(:list_type) { ::ListImports::ParseXml::MANGA_TYPE }

    context 'planned' do
      let(:status) { :planned }
      it { is_expected.to eq 'Plan to Read' }
    end

    context 'watching' do
      let(:status) { :watching }
      it { is_expected.to eq 'Reading' }
    end

    context 'completed' do
      let(:status) { :completed }
      it { is_expected.to eq 'Completed' }
    end

    context 'on_hold' do
      let(:status) { :on_hold }
      it { is_expected.to eq 'On-Hold' }
    end

    context 'dropped' do
      let(:status) { :dropped }
      it { is_expected.to eq 'Dropped' }
    end

    context 'rewatching' do
      let(:status) { :rewatching }

      context 'mal' do
        let(:is_mal) { true }
        it { is_expected.to eq 'Completed' }
      end

      context 'not mal' do
        let(:is_mal) { false }
        it { is_expected.to eq 'Rereading' }
      end
    end
  end
end
