describe ImageChecker do
  subject { described_class.valid? Rails.root.join(image_path) }

  context 'forbidden in rspec' do
    let(:image_path) { '' }
    it do
      expect { subject }.to raise_error 'ImageChecker.valid? must be stubbed in rspec'
    end
  end

  if ENV['CI_SERVER']
    context 'allowed in rspec' do
      before { allow_any_instance_of(ImageChecker).to receive :ensure_no_runs_in_rspec! }

      context 'jpg' do
        context 'valid' do
          let(:image_path) { 'spec/files/anime.jpg' }
          it { is_expected.to eq true }
        end

        context 'broken image' do
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
  end
end
