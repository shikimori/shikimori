describe Ad do
  subject(:ad) { Ad.new banner_type }
  let(:banner_type) { :yd_horizontal_poster_2x }

  before { allow_any_instance_of(Ad).to receive(:h).and_return h }

  let(:h) do
    double(
      params: params,
      ru_host?: is_ru_host,
      shikimori?: is_shikimori,
      current_user: user,
      spnsr_url: 'zxc'
    )
  end
  let(:params) { { controller: 'anime' } }
  let(:is_ru_host) { true }
  let(:is_shikimori) { true }
  let(:width) { 240 }
  let(:height) { 400 }
  let(:user) { nil }

  describe '#banner_type' do
    it { expect(ad.banner_type).to eq :yd_horizontal_poster_2x }

    context 'not allowed banner type' do
      let(:is_shikimori) { false }

      context 'with fallback' do
        it { expect(ad.banner_type).to eq :advrtr_240x400 }
      end

      context 'without fallback' do
        let(:banner_type) { :yd_wo_fallback }
        it { expect(ad.banner_type).to eq :yd_wo_fallback }
      end
    end
  end

  describe '#provider' do
    it { expect(ad.provider).to eq Ad::BANNERS[banner_type][:provider] }
  end

  describe '#allowed?' do
    before { allow(ad.policy).to receive(:allowed?).and_return :zz }
    it { expect(ad.allowed?).to eq :zz }
  end

  describe '#ad_params' do
    context 'yandex direct' do
      it do
        expect(ad.ad_params).to eq(
          blockId: banner_type,
          renderTo: banner_type,
          async: true
        )
      end
    end

    context 'advertur' do
      let(:banner_type) { :advrtr_240x400 }
      it { expect(ad.ad_params).to be_nil }
    end
  end

  describe '#css_class' do
    context 'yandex direct' do
      it { expect(ad.css_class).to eq "spnsrs_#{banner_type}" }
    end

    context 'advertur' do
      let(:banner_type) { :advrtr_240x400 }
      it { expect(ad.css_class).to eq "spnsrs_#{banner_type}" }
    end
  end

  describe '#to_html' do
    context 'advertur' do
      let(:banner_type) { :advrtr_240x400 }
      it do
        expect(ad.to_html).to eq(
          <<-HTML.gsub(/\n|^\ +/, '')
            <div class="b-spnsrs-advrtr_240x400">
              <center>
                <iframe src='zxc' width='240px' height='400px'>
              </center>
            </div>
          HTML
        )
      end
    end

    context 'yandex_direct' do
      let(:banner_type) { :yd_240x400 }
      it do
        expect(ad.to_html).to eq(
          <<-HTML.gsub(/\n|^\ +/, '')
            <div class="b-spnsrs-yd_240x400">
              <center>
                <div id='yd_240x400'></div>
              </center>
            </div>
          HTML
        )
      end
    end
  end
end
