describe Versions::ScreenshotsVersion do
  describe '#action' do
    let(:version) { build :screenshots_version, item_diff: { action: 'upload' } }
    it { expect(version.action).to eq 'upload' }
  end

  describe '#screenshots' do
    let(:screenshot) { create :screenshot }

    context 'upload or delete' do
      let(:version) { build :screenshots_version,
        item_diff: { screenshots: [screenshot.id] } }
      it { expect(version.screenshots).to eq [screenshot] }
    end

    context 'reposition' do
      let(:version) { build :screenshots_version,
        item_diff: { action: 'reposition', screenshots: [[0], [screenshot.id]] } }
      it { expect(version.screenshots).to eq [screenshot] }
    end
  end

  describe '#screenshots_prior' do
    let(:screenshot) { create :screenshot }

    context 'upload or delete' do
      let(:version) { build :screenshots_version,
        item_diff: { screenshots: [screenshot.id] } }
      it { expect{version.screenshots_prior}.to raise_error NotImplementedError }
    end

    context 'reposition' do
      let(:version) { build :screenshots_version,
        item_diff: { action: 'reposition', screenshots: [[screenshot.id], [0]] } }
      it { expect(version.screenshots_prior).to eq [screenshot] }
    end
  end

  describe '#apply_changes' do
    let(:version) { build :screenshots_version, item_diff: item_diff }

    context 'upload' do
      let(:screenshot) { create :screenshot, :uploaded }
      let(:item_diff) {{ action: 'upload', screenshots: [screenshot.id] }}

      before { version.apply_changes }

      it { expect(screenshot.reload.status).to be_nil }
    end

    context 'reposition' do
      let(:anime) { create :anime }
      let!(:screenshot_1) { create :screenshot, anime: anime, position: 9999 }
      let!(:screenshot_2) { create :screenshot, anime: anime, position: 9999 }
      let(:item_diff) {{
        action: 'reposition',
        screenshots: [
          [screenshot_1.id, screenshot_2.id],
          [screenshot_2.id, screenshot_1.id]
        ]
      }}

      before { version.apply_changes }

      it do
        expect(anime.screenshots).to eq [screenshot_2, screenshot_1]
        expect(screenshot_1.reload.position).to eq 1
        expect(screenshot_2.reload.position).to eq 0
      end
    end

    context 'delete' do
      let(:screenshot) { create :screenshot, :uploaded }
      let(:item_diff) {{ action: 'delete', screenshots: [screenshot.id] }}

      before { version.apply_changes }

      it { expect(screenshot.reload.status).to eq Screenshot::DELETED }
    end

    context 'unknown action' do
      let(:item_diff) {{ action: 'zzz' }}
      it { expect{version.apply_changes}.to raise_error ArgumentError }
    end
  end

  describe '#rollback_changes' do
    let(:version) { build :screenshots_version }
    it { expect{version.rollback_changes}.to raise_error NotImplementedError }
  end
end
