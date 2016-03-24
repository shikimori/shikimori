describe ImageUrlGenerator do
  let(:service) { ImageUrlGenerator.instance }

  let(:timestamp) { '1425232393' }
  before { Timecop.freeze '2015-03-01T20:53:13.183710+03:00' }
  after { Timecop.return }

  describe '#url' do
    subject { service.url entry, image_size }

    context 'production environment' do
      before { allow(Rails.env).to receive(:production?).and_return true }

      context 'anime' do
        let(:entry) { build_stubbed :anime, :with_image, id: 1 }

        context 'original' do
          let(:image_size) { :original }
          it { is_expected.to eq "//kawai.shikimori.org/system/animes/original/1.jpg?#{timestamp}" }
        end

        context 'x48' do
          let(:image_size) { :x48 }
          it { is_expected.to eq "//kawai.shikimori.org/system/animes/x48/1.jpg?#{timestamp}" }
        end
      end

      context 'club' do
        let(:entry) { build_stubbed :club, :with_logo, id: 2 }
        let(:image_size) { :x96 }
        it { is_expected.to eq "//moe.shikimori.org/system/clubs/x96/2.jpg?#{timestamp}" }
      end

      context 'user' do
        let(:entry) { build_stubbed :user, :with_avatar, id: 2 }
        let(:image_size) { :x160 }
        it { is_expected.to eq "//moe.shikimori.org/system/users/x160/2.png?#{timestamp}" }
      end

      context 'decorated user' do
        let(:entry) { build_stubbed(:user, :with_avatar, id: 3).decorate }
        let(:image_size) { :x48 }
        it { is_expected.to eq "//desu.shikimori.org/system/users/x48/3.png?#{timestamp}" }
      end
    end

    context 'test environment' do
      let(:entry) { build_stubbed :anime, :with_image, id: 1 }
      let(:image_size) { :original }
      it { is_expected.to eq "/system/animes/original/1.jpg?#{timestamp}" }
    end
  end
end
