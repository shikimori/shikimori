describe Versioneers::ScreenshotsVersioneer do
  let(:versioneer) { described_class.new anime }
  let(:anime) { create :anime }

  describe '#upload' do
    let(:image) { Rack::Test::UploadedFile.new 'spec/files/anime.jpg', 'image/jpg' }

    let!(:present_version) { nil }
    let!(:present_version_2) { nil }

    subject!(:result) { versioneer.upload image, user }

    let(:screenshot) { result.first }
    let(:version) { result.second }

    context 'wo existing version' do
      it do
        expect(screenshot).to be_persisted
        expect(screenshot).to_not be_changed
        expect(screenshot.status).to eq Screenshot::UPLOADED
        expect(anime.screenshots).to eq [screenshot]

        expect(version).to be_persisted
        expect(version).to_not be_changed
        expect(version).to have_attributes(
          item: anime,
          item_diff: {
            'action' => described_class::UPLOAD.to_s,
            described_class::KEY => [screenshot.id]
          },
          user: user
        )
      end
    end

    context 'with existing version' do
      let!(:present_version) do
        create :screenshots_version, {
          **version_params,
          created_at: created_at
        }
      end
      let(:created_at) { described_class::APPEND_TIMEOUT.ago + 1.minute }

      context 'matched version' do
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::UPLOAD.to_s,
              described_class::KEY => [123456]
            },
            user: user
          }
        end

        it do
          expect(screenshot).to be_persisted
          expect(screenshot).to_not be_changed
          expect(screenshot.status).to eq Screenshot::UPLOADED
          expect(anime.screenshots).to eq [screenshot]

          expect(version).to be_persisted
          expect(version).to_not be_changed
          expect(version).to eq present_version
          expect(version).to have_attributes version_params.except(:item_diff)
          expect(version.item_diff).to eq(
            'action' => described_class::UPLOAD.to_s,
            described_class::KEY => [123456, screenshot.id]
          )
        end

        context 'expired timeout' do
          let(:created_at) { described_class::APPEND_TIMEOUT.ago - 1.minute }
          it { expect(version).to_not eq present_version }
        end

        context 'newest version present with another action' do
          let!(:present_version_2) do
            create :screenshots_version, {
              **version_params,
              item_diff: {
                'action' => described_class::DELETE.to_s,
                described_class::KEY => [123456]
              },
              created_at: created_at + 1.minute
            }
          end

          it do
            expect(version).to_not eq present_version
            expect(version).to_not eq present_version_2
          end
        end
      end

      context 'another user version' do
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::UPLOAD.to_s,
              described_class::KEY => [123456]
            },
            user: build_stubbed(:user)
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'another item version' do
        let(:version_params) do
          {
            item: create(:anime),
            item_diff: {
              'action' => described_class::UPLOAD.to_s,
              described_class::KEY => [123456]
            },
            user: user
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'another field version' do
        let!(:present_version) { create :screenshots_version, version_params }
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::UPLOAD.to_s,
              Versioneers::VideosVersioneer::KEY => [123456]
            },
            user: user
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'another action version' do
        let(:version_params) do
          {
            item: create(:anime),
            item_diff: {
              'action' => described_class::REPOSITION,
              described_class::KEY => [screenshot.id]
            },
            user: user
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'not pending version' do
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::UPLOAD.to_s,
              described_class::KEY => [123456]
            },
            user: user,
            state: 'accepted'
          }
        end

        it { expect(version).to_not eq present_version }
      end
    end
  end

  describe '#delete' do
    let!(:present_version) {}
    let(:screenshot) { build_stubbed :screenshot }

    subject!(:version) { versioneer.delete screenshot.id, user }

    context 'wo existing version' do
      it do
        expect(version).to be_persisted
        expect(version).to have_attributes(
          item: anime,
          item_diff: {
            'action' => described_class::DELETE.to_s,
            described_class::KEY => [screenshot.id]
          },
          user: user
        )
      end
    end

    context 'with existing version' do
      let!(:present_version) { create :screenshots_version, version_params }

      context 'matched version' do
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::DELETE.to_s,
              described_class::KEY => [123456]
            },
            user: user
          }
        end

        it do
          expect(version).to be_persisted
          expect(version).to eq present_version
          expect(version).to have_attributes version_params.except(:item_diff)
          expect(version.item_diff).to eq(
            'action' => described_class::DELETE.to_s,
            described_class::KEY => [123456, screenshot.id]
          )
        end
      end

      context 'another author version' do
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::DELETE.to_s,
              described_class::KEY => [123456]
            },
            user: build_stubbed(:user)
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'another item version' do
        let(:version_params) do
          {
            item: create(:anime),
            item_diff: {
              'action' => described_class::DELETE.to_s,
              described_class::KEY => [123456]
            },
            user: user
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'another field version' do
        let!(:present_version) { create :screenshots_version, version_params }
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::DELETE.to_s,
              Versioneers::VideosVersioneer::KEY => [123456]
            },
            user: user
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'another action version' do
        let(:version_params) do
          {
            item: create(:anime),
            item_diff: {
              'action' => described_class::REPOSITION.to_s,
              described_class::KEY => [screenshot.id]
            },
            user: user
          }
        end

        it { expect(version).to_not eq present_version }
      end

      context 'not pending version' do
        let(:version_params) do
          {
            item: anime,
            item_diff: {
              'action' => described_class::UPLOAD.to_s,
              described_class::KEY => [123456]
            },
            user: user,
            state: 'accepted'
          }
        end

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
          'action' => described_class::REPOSITION.to_s,
          described_class::KEY => [
            [screenshot_1.id, screenshot_2.id],
            [screenshot_2.id, screenshot_1.id]
          ]
        },
        user: user
      )
    end
  end
end
