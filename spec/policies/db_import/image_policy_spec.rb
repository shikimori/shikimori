describe DbImport::ImagePolicy do
  let(:policy) { described_class.new target, image_url }
  subject { policy.need_import? }

  before do
    allow(File).to receive(:mtime).and_return mtime
    allow(target.image).to receive(:exists?).and_return is_exists
    allow(ImageChecker).to receive_message_chain(:new, :valid?).and_return is_valid
  end
  let(:mtime) { DbImport::ImagePolicy::OLD_INTERVAL.ago - 1.day }
  let(:is_valid) { true }
  let(:is_exists) { true }

  context 'anime' do
    let(:target) { build_stubbed :anime }
    let(:image_url) { 'http://zxc.vbn' }

    it { is_expected.to eq true }

    describe '#bad_image?' do
      it { is_expected.to eq true }

      context 'no image_url' do
        let(:image_url) { nil }
        it { is_expected.to eq false }
      end

      context 'na_series.gif' do
        let(:image_url) { 'http://zxc.vbn/na_series.gif' }
        it { is_expected.to eq false }
      end

      context 'na.gif' do
        let(:image_url) { 'http://zxc.vbn/na.gif' }
        it { is_expected.to eq false }
      end
    end

    describe '#no_image?' do
      let(:mtime) { described_class::OLD_INTERVAL.ago + 1.day }
      it { is_expected.to eq false }

      context 'new record' do
        let(:target) { build :anime }
        it { is_expected.to eq true }
      end

      context 'image not exists' do
        let(:is_exists) { false }
        it { is_expected.to eq true }
      end
    end

    describe 'image checker' do
      let(:mtime) { described_class::OLD_INTERVAL.ago + 1.day }
      it { is_expected.to eq false }

      context 'invalid image' do
        let(:is_valid) { false }
        it { is_expected.to eq true }
      end

      context 'valid image' do
        let(:is_valid) { true }
        it { is_expected.to eq false }
      end
    end

    describe '#file_expired?' do
      context 'ongoing' do
        let(:target) { build_stubbed :anime, status: :ongoing }

        context 'expired' do
          let(:mtime) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago - 1.day }
          it { is_expected.to eq true }
        end

        context 'not expired' do
          let(:mtime) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago + 1.day }
          it { is_expected.to eq false }
        end
      end

      context 'latest' do
        let(:target) { build_stubbed :anime, status: :released, aired_on: 1.month.ago }

        context 'expired' do
          let(:mtime) { DbImport::ImagePolicy::LATEST_INTERVAL.ago - 1.day }
          it { is_expected.to eq true }
        end

        context 'not expired' do
          let(:mtime) { DbImport::ImagePolicy::LATEST_INTERVAL.ago + 1.day }
          it { is_expected.to eq false }
        end
      end

      context 'old anime' do
        context 'expired' do
          let(:mtime) { DbImport::ImagePolicy::OLD_INTERVAL.ago - 1.day }
          it { is_expected.to eq true }
        end

        context 'not expired' do
          let(:mtime) { DbImport::ImagePolicy::OLD_INTERVAL.ago + 1.day }
          it { is_expected.to eq false }
        end
      end
    end
  end

  context 'character' do
    let(:target) { create :character }
    let(:image_url) { 'http://zxc.vbn' }

    let!(:person_role) { create :person_role, anime: anime, character: target }
    let!(:anime) { create :anime }

    it { is_expected.to eq true }

    describe '#file_expired?' do
      context 'ongoing' do
        let!(:anime) { create :anime, :ongoing }

        context 'expired' do
          let(:mtime) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago - 1.day }
          it { is_expected.to eq true }
        end

        context 'not expired' do
          let(:mtime) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago + 1.day }
          it { is_expected.to eq false }
        end
      end

      context 'old' do
        context 'expired' do
          let(:mtime) { DbImport::ImagePolicy::OLD_INTERVAL.ago - 1.day }
          it { is_expected.to eq true }
        end

        context 'not expired' do
          let(:mtime) { DbImport::ImagePolicy::OLD_INTERVAL.ago + 1.day }
          it { is_expected.to eq false }
        end
      end
    end
  end
end
