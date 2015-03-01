describe ImageUrlGenerator do
  let(:service) { ImageUrlGenerator.instance }

  before { Timecop.freeze '2011-01-01' }
  after { Timecop.return }

  describe '#url' do
    subject { service.url entry, image_size }

    context 'production environment' do
      before { allow(Rails.env).to receive(:production?).and_return true }

      context 'anime' do
        let(:entry) { build_stubbed :anime, :with_image, id: 1 }

        context 'original' do
          let(:image_size) { :original }
          it { should eq 'http://kawai.shikimori.org/images/anime/original/1.jpg?1293829200' }
        end

        context 'x48' do
          let(:image_size) { :x48 }
          it { should eq 'http://kawai.shikimori.org/images/anime/x48/1.jpg?1293829200' }
        end
      end

      context 'club' do
        let(:entry) { build_stubbed :group, :with_logo, id: 2 }
        let(:image_size) { :x96 }
        it { should eq 'http://moe.shikimori.org/images/group/x96/2.jpg?1293829200' }
      end

      context 'user' do
        let(:entry) { build_stubbed :user, :with_avatar, id: 2 }
        let(:image_size) { :x160 }
        it { should eq 'http://moe.shikimori.org/images/user/x160/2.png?1293829200' }
      end

      context 'decorated user' do
        let(:entry) { build_stubbed(:user, :with_avatar, id: 3).decorate }
        let(:image_size) { :x48 }
        it { should eq 'http://desu.shikimori.org/images/user/x48/3.png?1293829200' }
      end
    end

    context 'test environment' do
      let(:entry) { build_stubbed :anime, :with_image, id: 1 }
      let(:image_size) { :original }
      it { should eq '/images/anime/original/1.jpg?1293829200' }
    end
  end
end
