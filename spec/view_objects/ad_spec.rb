describe Ad do
  include_context :timecop

  subject(:ad) { Ad.new meta }

  let(:meta) { :menu_300x600 }
  let(:banner) { Ad::BANNERS[ad.banner_type] }

  before { allow_any_instance_of(Ad).to receive(:h).and_return h }
  let(:h) do
    double(
      params: params,
      ru_host?: is_ru_host,
      shikimori?: is_shikimori,
      current_user: user,
      spnsr_url: 'zxc',
      controller: double(
        instance_variable_get: nil,
        instance_variable_set: nil
      ),
      cookies: cookies
    )
  end
  let(:params) { { controller: 'anime' } }
  let(:is_ru_host) { true }
  let(:is_shikimori) { true }
  let(:width) { 240 }
  let(:height) { 400 }
  let(:user) { nil }
  let(:cookies) { {} }

  describe '#banner_type' do
    it { expect(ad.banner_type).to eq Ad::META_TYPES[:menu_300x600].first }

    describe 'meta changed by user preferences body_width_x1000' do
      let(:user) { build_stubbed :user, preferences: preferences }
      let(:preferences) { build_stubbed :user_preferences, body_width: body_width }

      context 'x1000 site width' do
        let(:meta) { %i[menu_300x600 menu_300x250].sample }
        let(:body_width) { :x1000 }

        it { expect(ad.banner_type).to eq Ad::META_TYPES[:menu_240x400].first }
      end

      context 'x1200 site width' do
        let(:body_width) { :x1200 }
        it { expect(ad.banner_type).to eq Ad::META_TYPES[:menu_300x600].first }
      end
    end

    describe 'meta changed by controller' do
      context 'topics' do
        let(:meta) { :menu_240x400 }
        let(:params) { { controller: 'topics' } }
        it { expect(ad.banner_type).to eq Ad::META_TYPES[:menu_300x600].first }
      end
    end
  end

  describe '#platform' do
    it { expect(ad.platform).to eq Ad::BANNERS[:yd_300x600][:platform] }
  end

  describe '#provider' do
    it { expect(ad.provider).to eq Ad::BANNERS[Ad::META_TYPES[:menu_300x600].first][:provider] }
  end

  describe '#allowed?' do
    before do
      allow(ad.policy).to receive(:allowed?).and_return is_allowed
      allow(h.controller)
        .to receive(:instance_variable_get)
        .with(:"@is_#{banner[:placement]}_ad_shown")
        .and_return is_ad_shown

      ad.instance_variable_set :'@rules', rules
    end
    let(:is_allowed) { true }
    let(:is_ad_shown) { false }
    let(:rules) { nil }

    it { expect(ad).to be_allowed }

    context 'ad shown' do
      let(:is_ad_shown) { true }
      it { expect(ad).to_not be_allowed }
    end

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
      before { ad.instance_variable_set '@banner_type', banner_type }
      let(:banner_type) { :yd_240x500 }

      it do
        expect(ad.ad_params).to eq(
          blockId: Ad::BANNERS[banner_type][:yandex_id],
          renderTo: banner_type,
          async: true
        )
      end
    end

    # context 'other' do
    #   before { ad.instance_variable_set '@banner_type', banner_type }
    #   let(:banner_type) { :yd_240x500 }
    #   it { expect(ad.ad_params).to be_nil }
    # end
  end

  describe '#css_class' do
    it { expect(ad.css_class).to eq "spns_#{ad.banner_type}" }
  end

  describe '#to_html' do
    before { ad.instance_variable_set '@banner_type', banner_type }

    context 'advertur' do
      let(:banner_type) { :advrtr_240x400 }
      it do
        expect(ad.to_html).to eq(
          <<-HTML.gsub(/\n|^\ +/, '')
            <div class="b-spns-advrtr_240x400">
              <center>
                <iframe src='zxc' width='240px' height='400px'>
              </center>
            </div>
          HTML
        )
      end
    end

    # context 'istari' do
      # let(:cookie_key) { Ad::BANNERS[:istari_x300][:rules][:cookie] }

      # context 'without rules' do
        # let(:banner_type) { :istari_x1170 }
        # it do
          # expect(ad.to_html).to eq(
            # <<-HTML.gsub(/\n|^\ +/, '')
              # <div class="b-spns-istari_x1170">
                # <center>
                  # <a href='http://kimi.istaricomics.com'>
                    # <img src='/assets/globals/events/i1_2.jpg' srcset='/assets/globals/events/i1_2@2x.jpg 2x'>
                  # </a>
                # </center>
              # </div>
            # HTML
          # )
        # end
      # end

      # context 'with rules' do
      #   let(:banner_type) { :istari_x300 }

      #   context 'without show in cookies' do
      #     it do
      #       expect(h.cookies[cookie_key]).to eq(
      #         value: [Time.zone.now].map(&:to_i).join(Ads::Rules::DELIMITER),
      #         expires: 1.week.from_now
      #       )
      #     end
      #   end

      #   context 'with show in cookies' do
      #     let(:cookies) { { cookie_key => [1.day.ago].map(&:to_i).join(Ads::Rules::DELIMITER) } }
      #     it do
      #       expect(h.cookies[Ad::BANNERS[:istari_x300][:rules][:cookie]]).to eq(
      #         value: [1.day.ago, Time.zone.now].map(&:to_i).join(Ads::Rules::DELIMITER),
      #         expires: 1.week.from_now
      #       )
      #     end
      #   end
      # end
    # end

    context 'yandex_direct' do
      let(:banner_type) { :yd_240x400 }
      it do
        expect(ad.to_html).to eq(
          <<-HTML.gsub(/\n|^\ +/, '')
            <div class="b-spns-yd_240x400">
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
