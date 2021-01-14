describe ImageUrlGenerator do
  let(:service) { described_class.instance }

  let(:timestamp) { '1425232393' }
  include_context :timecop, '2015-03-01T20:53:13.183710+03:00'

  describe '#url' do
    subject { service.url entry, image_size }

    context 'production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return true
        allow(Rails.env).to receive(:test?).and_return false
      end
      let(:protocol) { Shikimori::PROTOCOLS[:production] }
      let(:domain) { Shikimori::DOMAINS[:production] }

      context 'anime' do
        let(:entry) { build_stubbed :anime, :with_image, id: 1 }

        context 'original' do
          let(:image_size) { :original }
          it do
            is_expected.to eq(
              "#{protocol}://kawai.#{domain}/system/animes/original/1.jpg?#{timestamp}"
            )
          end
        end

        context 'x48' do
          let(:image_size) { :x48 }
          it do
            is_expected.to eq(
              "#{protocol}://kawai.#{domain}/system/animes/x48/1.jpg?#{timestamp}"
            )
          end
        end
      end

      context 'club' do
        let(:entry) { build_stubbed :club, :with_logo, id: 2 }
        let(:image_size) { :x96 }
        it do
          is_expected.to eq(
            "#{protocol}://moe.#{domain}/system/clubs/x96/2.jpg?#{timestamp}"
          )
        end
      end

      context 'user' do
        let(:entry) { build_stubbed :user, :with_avatar, id: 2 }
        let(:image_size) { :x160 }
        it do
          is_expected.to eq(
            "#{protocol}://moe.#{domain}/system/users/x160/2.png?#{timestamp}"
          )
        end
      end

      context 'decorated user' do
        let(:entry) { build_stubbed(:user, :with_avatar, id: 3).decorate }
        let(:image_size) { :x48 }
        it do
          is_expected.to eq(
            "#{protocol}://desu.#{domain}/system/users/x48/3.png?#{timestamp}"
          )
        end
      end
    end

    context 'test environment' do
      let(:entry) { build_stubbed :anime, :with_image, id: 1 }
      let(:image_size) { :original }
      it { is_expected.to eq "/system/animes/original/1.jpg?#{timestamp}" }
    end
  end
end
