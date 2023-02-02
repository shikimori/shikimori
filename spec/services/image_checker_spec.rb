describe ImageChecker do
  subject { described_class.valid? Rails.root.join(image_path) }

  context 'no image' do
    let(:image_path) { 'spec/files/zxc' }
    it { is_expected.to eq false }
  end

  context 'jpg' do
    context 'valid' do
      let(:image_path) { 'spec/files/anime.jpg' }
      it { is_expected.to eq true }
    end

    context 'broken image', :ci_only do
      # NOTE: "Premature end of JPEG file" printed here
      let(:image_path) { 'spec/files/poster_broken.jpg' }
      it { is_expected.to eq false }
    end

    context 'incomplete image' do
      let(:image_path) { 'spec/files/poster_incomplete.jpg' }
      it { is_expected.to eq false }
    end
  end

  context 'png' do
    context 'valid' do
      let(:image_path) { 'spec/files/sample.png' }
      it { is_expected.to eq true }
    end

    context 'incomplete image' do
      let(:image_path) { 'spec/files/poster_incomplete.png' }
      it { is_expected.to eq false }
    end
  end
end
