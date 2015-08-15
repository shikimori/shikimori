describe Versions::ScreenshotsVersion do
  describe '#action' do
    let(:version) { build :screenshots_version, item_diff: { action: 'upload' } }
    it { expect(version.action).to eq 'upload' }
  end

  describe '#screenshots' do
    let(:screenshot) { create :screenshot }
    let(:version) { build :screenshots_version, item_diff: { screenshots: [screenshot.id] } }
    it { expect(version.screenshots).to eq [screenshot] }
  end
end
