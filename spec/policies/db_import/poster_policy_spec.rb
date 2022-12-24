describe DbImport::PosterPolicy do
  let(:policy) { described_class.new target, image_url }
  subject { policy.need_import? }

  let(:poster) { build_stubbed :poster, created_at: downloaded_at }
  let(:downloaded_at) { described_class::OLD_INTERVAL.ago - 1.day }

  context 'anime' do
    let(:target) { build_stubbed :anime, poster: poster, desynced: desynced }
    let(:desynced) { [] }
    let(:image_url) { 'http://zxc.vbn' }

    it { is_expected.to eq true }

    describe '#invalid_target?' do
      context 'new record' do
        before { allow(target).to receive(:new_record?).and_return true }
        it { is_expected.to eq false }
      end

      context 'new record' do
        before { allow(target).to receive(:valid?).and_return false }
        it { is_expected.to eq false }
      end
    end

    describe '#bad_image?' do
      describe 'has image url' do
        it { is_expected.to eq true }

        context 'na_series.gif' do
          let(:image_url) { 'http://zxc.vbn/na_series.gif' }
          it { is_expected.to eq false }
        end

        context 'na.gif' do
          let(:image_url) { 'http://zxc.vbn/na.gif' }
          it { is_expected.to eq false }
        end
      end

      context 'no image_url' do
        let(:image_url) { ['', nil].sample }
        it { is_expected.to eq false }
      end
    end

    describe '#desynced_poster?' do
      context 'desynced' do
        let(:desynced) { ['poster'] }
        it { is_expected.to eq false }
      end
    end

    describe '#poster_expired?' do
      context 'no existing poster' do
        let(:poster) { nil }
        it { is_expected.to eq true }
      end

      context 'has existing poster' do
        context 'ongoing' do
          let(:target) { build_stubbed :anime, poster: poster, status: :ongoing }

          context 'expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago - 1.day }
            it { is_expected.to eq true }
          end

          context 'not expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago + 1.day }
            it { is_expected.to eq false }
          end
        end

        context 'latest' do
          let(:target) do
            build_stubbed :anime, poster: poster, status: :released, aired_on: 1.month.ago
          end

          context 'expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::LATEST_INTERVAL.ago - 1.day }
            it { is_expected.to eq true }
          end

          context 'not expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::LATEST_INTERVAL.ago + 1.day }
            it { is_expected.to eq false }
          end
        end

        context 'old anime' do
          context 'expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::OLD_INTERVAL.ago - 1.day }
            it { is_expected.to eq true }
          end

          context 'not expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::OLD_INTERVAL.ago + 1.day }
            it { is_expected.to eq false }
          end
        end
      end
    end
  end

  context 'character' do
    let(:target) { build_stubbed :character, poster: poster }
    let(:image_url) { 'http://zxc.vbn' }

    before do
      allow(target)
        .to receive_message_chain(:animes, :where, :any?)
        .and_return is_ongoing
    end
    let(:is_ongoing) { [true, false].sample }

    it { is_expected.to eq true }

    describe '#poster_expired?' do
      context 'no existing poster' do
        let(:poster) { nil }
        it { is_expected.to eq true }
      end

      context 'has existing poster' do
        context 'ongoing' do
          let(:is_ongoing) { true }

          context 'expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago - 1.day }
            it { is_expected.to eq true }
          end

          context 'not expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::ONGOING_INTERVAL.ago + 1.day }
            it { is_expected.to eq false }
          end
        end

        context 'not ongoing' do
          let!(:is_ongoing) { false }

          context 'expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::OLD_INTERVAL.ago - 1.day }
            it { is_expected.to eq true }
          end

          context 'not expired' do
            let(:downloaded_at) { DbImport::ImagePolicy::OLD_INTERVAL.ago + 1.day }
            it { is_expected.to eq false }
          end
        end
      end
    end
  end
end
