describe ImageChecker do
  subject { described_class.valid? Rails.root.join(image_path) }
  let(:image_path) { 'spec/files/anime.jpg' }

  context 'forbidden in rspec' do
    it do
      expect { subject }.to raise_error 'ImageChecker.valid? must be stubbed in rspec'
    end
  end

  if ENV['CI_SERVER']
    context 'allowed in rspec' do
      before { allow_any_instance_of(ImageChecker).to receive :ensure_no_runs_in_rspec! }

      it { is_expected.to eq true }

      context 'broken poster' do
        # NOTE: "Premature end of JPEG file" printed here
        let(:image_path) { 'spec/files/poster_broken.jpg' }
        it { is_expected.to eq false }
      end

      context 'incomplete poster' do
        let(:image_path) { 'spec/files/poster_incomplete.jpg' }
        it { is_expected.to eq false }
      end
    end
  end
end
