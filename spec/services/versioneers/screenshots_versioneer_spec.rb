describe Versioneers::ScreenshotsVersioneer do
  let(:versioneer) { Versioneers::ScreenshotsVersioneer.new anime }
  let(:anime) { create :anime }
  let(:user) { create :user }

  describe '#upload' do
    let(:image) { Rack::Test::UploadedFile.new 'spec/images/anime.jpg', 'image/jpg' }

    let!(:present_version) { }
    subject!(:result) { versioneer.upload image, user }

    let(:screenshot) { result.first }
    let(:version) { result.second }

    context 'wo existing version' do
      it do
        expect(screenshot).to be_persisted
        expect(screenshot.status).to eq Screenshot::UPLOADED
        expect(anime.screenshots).to eq [screenshot]

        expect(version).to be_persisted
        expect(version).to have_attributes(
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::UPLOAD,
            Versioneers::ScreenshotsVersioneer::KEY => [screenshot.id]
          },
          user: user,
        )
      end
    end

    context 'with existing version' do
      let!(:present_version) { create :screenshots_version, version_params }

      context 'matched version' do
        let(:version_params) {{
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::UPLOAD,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: user,
        }}

        it do
          expect(screenshot).to be_persisted
          expect(screenshot.status).to eq Screenshot::UPLOADED
          expect(anime.screenshots).to eq [screenshot]

          expect(version).to be_persisted
          expect(version).to eq present_version
          expect(version).to have_attributes version_params.except(:item_diff)
          expect(version.item_diff).to eq(
            'action' => Versioneers::ScreenshotsVersioneer::UPLOAD,
            Versioneers::ScreenshotsVersioneer::KEY => [123456, screenshot.id]
          )
        end
      end

      context 'another author version' do
        let(:version_params) {{
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::UPLOAD,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: build_stubbed(:user),
        }}

        it { expect(version).to_not eq present_version }
      end

      context 'another item version' do
        let(:version_params) {{
          item: build_stubbed(:anime),
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::UPLOAD,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: user,
        }}

        it { expect(version).to_not eq present_version }
      end

      context 'another action version' do
        let(:version_params) {{
          item: build_stubbed(:anime),
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::REPOSITION,
            Versioneers::ScreenshotsVersioneer::KEY => [screenshot.id]
          },
          user: user,
        }}

        it { expect(version).to_not eq present_version }
      end

      context 'not pending version' do
        let(:version_params) {{
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::UPLOAD,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: user,
          state: 'accepted'
        }}

        it { expect(version).to_not eq present_version }
      end
    end
  end

  describe '#delete' do
    let!(:present_version) { }
    let(:screenshot) { build_stubbed :screenshot }

    subject!(:version) { versioneer.delete screenshot.id, user }

    context 'wo existing version' do
      it do
        expect(version).to be_persisted
        expect(version).to have_attributes(
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::DELETE,
            Versioneers::ScreenshotsVersioneer::KEY => [screenshot.id]
          },
          user: user,
        )
      end
    end

    context 'with existing version' do
      let!(:present_version) { create :screenshots_version, version_params }

      context 'matched version' do
        let(:version_params) {{
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::DELETE,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: user,
        }}

        it do
          expect(version).to be_persisted
          expect(version).to eq present_version
          expect(version).to have_attributes version_params.except(:item_diff)
          expect(version.item_diff).to eq(
            'action' => Versioneers::ScreenshotsVersioneer::DELETE,
            Versioneers::ScreenshotsVersioneer::KEY => [123456, screenshot.id]
          )
        end
      end

      context 'another author version' do
        let(:version_params) {{
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::DELETE,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: build_stubbed(:user),
        }}

        it { expect(version).to_not eq present_version }
      end

      context 'another item version' do
        let(:version_params) {{
          item: build_stubbed(:anime),
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::DELETE,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: user,
        }}

        it { expect(version).to_not eq present_version }
      end

      context 'another action version' do
        let(:version_params) {{
          item: build_stubbed(:anime),
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::REPOSITION,
            Versioneers::ScreenshotsVersioneer::KEY => [screenshot.id]
          },
          user: user,
        }}

        it { expect(version).to_not eq present_version }
      end

      context 'not pending version' do
        let(:version_params) {{
          item: anime,
          item_diff: {
            'action' => Versioneers::ScreenshotsVersioneer::UPLOAD,
            Versioneers::ScreenshotsVersioneer::KEY => [123456]
          },
          user: user,
          state: 'accepted'
        }}

        it { expect(version).to_not eq present_version }
      end
    end
  end

  describe '#reposition' do
    let(:screenshot_1) { create :screenshot, anime: anime, position: 0, url: rand }
    let(:screenshot_2) { create :screenshot, anime: anime, position: 1, url: rand }

    subject!(:version) { versioneer.reposition [screenshot_2.id.to_s, screenshot_1.id.to_s], user }

    it do
      expect(version).to be_persisted
      expect(version).to have_attributes(
        item: anime,
        item_diff: {
          'action' => Versioneers::ScreenshotsVersioneer::REPOSITION,
          Versioneers::ScreenshotsVersioneer::KEY => [
            [screenshot_1.id, screenshot_2.id],
            [screenshot_2.id, screenshot_1.id]
          ]
        },
        user: user,
      )
    end
  end
end
