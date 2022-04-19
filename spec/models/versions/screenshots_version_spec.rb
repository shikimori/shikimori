describe Versions::ScreenshotsVersion do
  describe '#action' do
    let(:version) { build :screenshots_version, item_diff: { action: 'upload' } }
    it { expect(version.action).to eq Versions::ScreenshotsVersion::Actions[:upload] }
  end

  describe '#screenshots' do
    let(:screenshot) { create :screenshot }

    context 'upload or delete' do
      let(:version) do
        build :screenshots_version,
          item_diff: {
            action: %i[upload delete].sample,
            screenshots: [screenshot.id]
          }
      end
      it { expect(version.screenshots).to eq [screenshot] }
    end

    context 'reposition' do
      let(:version) do
        build :screenshots_version,
          item_diff: {
            action: Versions::ScreenshotsVersion::Actions[:reposition],
            screenshots: [[0], [screenshot.id]]
          }
      end
      it { expect(version.screenshots).to eq [screenshot] }
    end
  end

  describe '#screenshots_prior' do
    let(:screenshot) { create :screenshot }

    context 'upload or delete' do
      let(:version) do
        build :screenshots_version,
          item_diff: {
            action: %i[upload delete].sample,
            screenshots: [screenshot.id]
          }
      end
      it { expect { version.screenshots_prior }.to raise_error NotImplementedError }
    end

    context 'reposition' do
      let(:version) do
        build :screenshots_version,
          item_diff: {
            action: Versions::ScreenshotsVersion::Actions[:reposition],
            screenshots: [[screenshot.id], [0]]
          }
      end
      it { expect(version.screenshots_prior).to eq [screenshot] }
    end
  end

  describe '#apply_changes' do
    let(:version) { build :screenshots_version, state: :pending, item_diff: item_diff }

    context 'upload' do
      let(:screenshot) { create :screenshot, :uploaded }
      let(:item_diff) do
        {
          action: Versions::ScreenshotsVersion::Actions[:upload],
          screenshots: [screenshot.id]
        }
      end
      subject! { version.apply_changes }

      it { expect(screenshot.reload.status).to be_nil }
    end

    context 'reposition' do
      let(:anime) { create :anime }
      let!(:screenshot_1) { create :screenshot, anime: anime, position: 9999 }
      let!(:screenshot_2) { create :screenshot, anime: anime, position: 9999 }
      let(:item_diff) do
        {
          action: Versions::ScreenshotsVersion::Actions[:reposition],
          screenshots: [
            [screenshot_1.id, screenshot_2.id],
            [screenshot_2.id, screenshot_1.id]
          ]
        }
      end
      subject! { version.apply_changes }

      it do
        expect(anime.screenshots).to eq [screenshot_2, screenshot_1]
        expect(screenshot_1.reload.position).to eq 1
        expect(screenshot_2.reload.position).to eq 0
      end
    end

    context 'delete' do
      let(:screenshot) { create :screenshot, :uploaded }
      let(:item_diff) do
        {
          action: Versions::ScreenshotsVersion::Actions[:delete],
          screenshots: [screenshot.id]
        }
      end
      subject! { version.apply_changes }

      it { expect(screenshot.reload.status).to eq Screenshot::DELETED }
    end
  end

  describe '#rollback_changes' do
    let(:version) { build :screenshots_version, state: :accepted, item_diff: item_diff }

    context 'upload' do
      let(:screenshot) { create :screenshot, :accepted }
      let(:item_diff) do
        {
          action: Versions::ScreenshotsVersion::Actions[:upload],
          screenshots: [screenshot.id]
        }
      end
      subject! { version.rollback_changes }

      it { expect(screenshot.reload.status).to eq Screenshot::DELETED }
    end

    context 'reposition' do
      let(:anime) { create :anime }
      let!(:screenshot_1) { create :screenshot, anime: anime, position: 1 }
      let!(:screenshot_2) { create :screenshot, anime: anime, position: 0 }
      let(:item_diff) do
        {
          action: Versions::ScreenshotsVersion::Actions[:reposition],
          screenshots: [
            [screenshot_1.id, screenshot_2.id],
            [screenshot_2.id, screenshot_1.id]
          ]
        }
      end
      subject! { version.rollback_changes }

      it do
        expect(anime.screenshots).to eq [screenshot_1, screenshot_2]
        expect(screenshot_1.reload.position).to eq 0
        expect(screenshot_2.reload.position).to eq 1
      end
    end

    context 'delete' do
      let(:screenshot) { create :screenshot, :deleted }
      let(:item_diff) do
        {
          action: Versions::ScreenshotsVersion::Actions[:delete],
          screenshots: [screenshot.id]
        }
      end
      subject! { version.rollback_changes }

      it { expect(screenshot.reload.status).to be_nil }
    end
  end

  describe '#sweep_deleted' do
    let(:screenshot) { create :screenshot }
    let(:version) do
      build :screenshots_version,
        item_diff: {
          action: action,
          screenshots: screenshots
        }
    end

    subject! { version.sweep_deleted }

    context 'upload' do
      let(:action) { Versions::ScreenshotsVersion::Actions[:upload] }
      let(:screenshots) { [screenshot.id] }
      it { expect { screenshot.reload }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'reposition' do
      let(:action) { Versions::ScreenshotsVersion::Actions[:reposition] }
      let(:screenshots) { [[screenshot.id], [screenshot.id]] }
      it { expect(screenshot.reload).to be_persisted }
    end

    context 'delete' do
      let(:action) { Versions::ScreenshotsVersion::Actions[:delete] }
      let(:screenshots) { [screenshot.id] }
      it { expect(screenshot.reload).to be_persisted }
    end
  end
end
