describe Ad do
  include_context :timecop

  subject(:ad) { Ad.new banner_type }

  let(:banner_type) { :yd_poster_x300_2x }
  let(:banner) { Ad::BANNERS[banner_type] }

  before { allow_any_instance_of(Ad).to receive(:h).and_return h }

  let(:h) do
    double(
      params: params,
      ru_host?: is_ru_host,
      shikimori?: is_shikimori,
      current_user: user,
      spnsr_url: 'zxc',
      controller: controller_stub,
      cookies: cookies
    )
  end
  let(:params) { { controller: 'anime' } }
  let(:is_ru_host) { true }
  let(:is_shikimori) { true }
  let(:width) { 240 }
  let(:height) { 400 }
  let(:user) { nil }
  let(:controller_stub) do
    double(
      instance_variable_get: nil,
      instance_variable_set: nil
    )
  end
  let(:cookies) { {} }

  describe '#banner_type' do
    it { expect(ad.banner_type).to eq banner_type }

    describe 'yd_poster_x300_2x -> yd_rtb_x240' do
      let(:user) { build_stubbed :user, preferences: preferences }
      let(:preferences) { build_stubbed :user_preferences, body_width: body_width }

      context 'x1000 site width' do
        let(:body_width) { :x1000 }
        it { expect(ad.banner_type).to eq :yd_poster_x240_2x }
      end

      context 'x1200 site width' do
        let(:body_width) { :x1200 }
        it { expect(ad.banner_type).to eq banner_type }
      end
    end

    describe 'yd_rtb_x240 -> yd_poster_x300_2x' do
      let(:params) { { controller: 'topics' } }

      context 'not yd_rtb_x240' do
        let(:banner_type) { :advrtr_x240 }
        it { expect(ad.banner_type).to eq banner_type }
      end

      context 'yd_rtb_x240' do
        let(:banner_type) { :yd_rtb_x240 }
        it { expect(ad.banner_type).to eq :yd_poster_x300_2x }
      end
    end

    context 'not allowed banner type' do
      let(:is_shikimori) { false }

      context 'with fallback' do
        it { expect(ad.banner_type).to eq :advrtr_x240 }
      end

      context 'without fallback' do
        before do
          Ad::BANNERS[banner_type] = {
            provider: Types::Ad::Provider[:yandex_direct]
          }
        end
        let(:banner_type) { :yd_wo_fallback }

        it { expect(ad.banner_type).to eq :yd_wo_fallback }
      end
    end
  end

  describe '#provider' do
    it { expect(ad.provider).to eq Ad::BANNERS[banner_type][:provider] }
  end

  describe '#allowed?' do
    before do
      allow(ad.policy).to receive(:allowed?).and_return is_allowed
      ad.instance_variable_set :'@rules', rules
    end
    let(:is_allowed) { true }
    let(:rules) { nil }

    it { expect(ad).to be_allowed }

    context 'not allowed' do
      let(:is_allowed) { false }
      it { expect(ad).to_not be_allowed }
    end

    context 'rules' do
      let(:rules) { double show?: is_show }

      context 'to show' do
        let(:is_show) { true }
        it { expect(ad).to be_allowed }
      end

      context 'not to show' do
        let(:is_show) { false }
        it { expect(ad).to_not be_allowed }
      end
    end
  end

  describe '#ad_params' do
    context 'yandex direct' do
      it do
        expect(ad.ad_params).to eq(
          blockId: Ad::BANNERS[banner_type][:yandex_id],
          renderTo: banner_type,
          async: true
        )
      end
    end

    context 'advertur' do
      let(:banner_type) { :advrtr_x240 }
      it { expect(ad.ad_params).to be_nil }
    end

    context 'istari' do
      let(:banner_type) { :istari_x300 }
      it { expect(ad.ad_params).to be_nil }
    end
  end

  describe '#css_class' do
    context 'yandex direct' do
      it { expect(ad.css_class).to eq "spnsrs_#{banner_type}" }
    end

    context 'advertur' do
      let(:banner_type) { :advrtr_x240 }
      it { expect(ad.css_class).to eq "spnsrs_#{banner_type}" }
    end
  end

  describe '#to_html' do
    subject! { ad.to_html }

    it do
      expect(h.controller)
        .to have_received(:instance_variable_set)
        .with(:"@is_#{banner[:placement]}_ad_shown", true)
    end

    context 'advertur' do
      let(:banner_type) { :advrtr_x240 }
      it do
        is_expected.to eq(
          <<-HTML.gsub(/\n|^\ +/, '')
            <div class="b-spnsrs-advrtr_x240">
              <center>
                <iframe src='zxc' width='240px' height='400px'>
              </center>
            </div>
          HTML
        )
      end
    end

    context 'istari' do
      let(:cookie_key) { Ad::BANNERS[:istari_x300][:rules][:cookie] }

      context 'without rules' do
        let(:banner_type) { :istari_x1170 }
        it do
          is_expected.to eq(
            <<-HTML.gsub(/\n|^\ +/, '')
              <div class="b-spnsrs-istari_x1170">
                <center>
                  <a href='https://vk.com/istaricomics'>
                    <img src='/assets/globals/events/i1_2.jpg' srcset='/assets/globals/events/i1_2@2x.jpg 2x'>
                  </a>
                </center>
              </div>
            HTML
          )
        end
      end

      context 'with rules' do
        let(:banner_type) { :istari_x300 }

        context 'without show in cookies' do
          it do
            expect(h.cookies[cookie_key]).to eq(
              value: [Time.zone.now].map(&:to_i).join('|'),
              expires: 1.week.from_now
            )
          end
        end

        context 'with show in cookies' do
          let(:cookies) { { cookie_key => [1.day.ago].map(&:to_i).join('|') } }
          it do
            expect(h.cookies[Ad::BANNERS[:istari_x300][:rules][:cookie]]).to eq(
              value: [1.day.ago, Time.zone.now].map(&:to_i).join('|'),
              expires: 1.week.from_now
            )
          end
        end
      end
    end

    context 'yandex_direct' do
      let(:banner_type) { :yd_rtb_x240 }
      it do
        is_expected.to eq(
          <<-HTML.gsub(/\n|^\ +/, '')
            <div class="b-spnsrs-yd_rtb_x240">
              <center>
                <div id='yd_rtb_x240'></div>
              </center>
            </div>
          HTML
        )
      end
    end
  end
end
