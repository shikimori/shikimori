class Ad < ViewObjectBase # rubocop:disable ClassLength
  # present advertur blocks
  # block_1: [92_129, 2_731],
  # block_2: [92_445, 1_256],
  # block_3: [92_485, nil]

  # CACHE_KEY = Digest::MD5.hexdigest(META_TYPES.to_json)

  attr_reader :banner_type, :policy

  def initialize meta
    meta = Types::Ad::Meta[:menu_240x400] if switch_to_x240? meta
    meta = Types::Ad::Meta[:menu_300x600] if switch_to_x300? meta

    META_TYPES[h.clean_host?][Types::Ad::Meta[meta]].each do |type|
      switch_banner Types::Ad::Type[type]
      break if allowed?
    end
  end

  def allowed?
    if h.controller.instance_variable_get controller_key(banner[:placement])
      false
    else
      policy.allowed? && (!@rules || @rules.show?)
    end
  end

  def provider
    banner[:provider]
  end

  def placeholder?
    Rails.env.development? && !special?
  end

  def platform
    banner[:platform]
  end

  def ad_params
    return unless yandex_direct?

    {
      blockId: banner[:yandex_id],
      renderTo: @banner_type,
      async: true
    }
  end

  def css_class
    "spns_#{@banner_type}"
  end

  def to_html
    finalize

    <<-HTML.gsub(/\n|^\ +/, '')
      <div class="b-spns-#{@banner_type}">
        <center>
          #{ad_html}
        </center>
      </div>
    HTML
  end

private

  def switch_banner banner_type
    @banner_type = banner_type
    @policy = build_policy
    @rules = build_rules
  end

  def build_policy
    AdsPolicy.new(
      user: h.current_user,
      ad_provider: provider,
      is_ru_host: h.ru_host?,
      is_disabled: h.cookies["#{css_class}_disabled"].present?
    )
  end

  def build_rules
    return unless banner[:rules]

    Ads::Rules.new banner[:rules], h.cookies[banner[:rules][:cookie]]
  end

  def banner
    BANNERS[h.clean_host?][@banner_type]
  end

  def yandex_direct?
    provider == Types::Ad::Provider[:yandex_direct]
  end

  def mytarget?
    provider == Types::Ad::Provider[:mytarget]
  end

  def special?
    provider == Types::Ad::Provider[:special]
  end

  def banner?
    banner[:images].present?
  end

  def html?
    banner[:html].present?
  end

  def iframe?
    provider == Types::Ad::Provider[:advertur]
  end

  def ad_html # rubocop:disable all
    if placeholder?
      width, height =
        if @banner_type =~ /(?<width>\d+)x(?<height>\d+)/
          [$LAST_MATCH_INFO[:width], $LAST_MATCH_INFO[:height]]
        else
          [500, 500]
        end

      "<div class='ad-placeholder' style='width: #{width}px; "\
        "height: #{height}px;' data-banner_type='#{@banner_type}' >"

    elsif yandex_direct?
      "<div id='#{@banner_type}'></div>"

    elsif mytarget?
      <<-HTML.squish
        <ins
          class="mrg-tag"
          style="display:inline-block;text-decoration: none;"
          data-ad-client="ad-#{banner[:mytarget_id]}"
          data-ad-slot="#{banner[:mytarget_id]}"></ins>
      HTML

    elsif banner?
      image = banner[:images].sample

      image_html =
        if image[:src_2x]
          "<img src='#{image[:src]}' srcset='#{image[:src_2x]} 2x'>"
        else
          "<img src='#{image[:src]}'>"
        end

      pixel_html = "<img src='#{banner[:pixel]}' width='0' height='0'>" if banner[:pixel]

      "#{pixel_html}<a href='#{banner[:url] || image[:url]}'>#{image_html}</a>"
    elsif html?
      banner[:html]

    elsif iframe?
      "<iframe src='#{advertur_url}' width='#{banner[:width]}px' height='#{banner[:height]}px'>"

    else
      raise ArgumentError
    end
  end

  def advertur_url
    h.spnsr_url(
      banner[:advertur_id],
      width: banner[:width],
      height: banner[:height],
      container_class: css_class,
      protocol: false
    )
  end

  def switch_to_x240? meta
    [
      Types::Ad::Meta[:menu_300x600],
      Types::Ad::Meta[:menu_300x250]
    ].include?(meta) && h.current_user&.preferences&.body_width_x1000?
  end

  def switch_to_x300? meta
    [
      Types::Ad::Meta[:menu_240x400]
    ].include?(meta) && h.params[:controller].in?(%w[topics])
  end

  def finalize
    h.controller.instance_variable_set controller_key(banner[:placement]), true

    if @rules
      h.cookies[banner[:rules][:cookie]] = {
        value: @rules.export_shows,
        expires: 1.week.from_now
      }
    end
  end

  def controller_key placement
    :"@is_#{placement}_ad_shown"
  end

  BANNERS = {
    true => {
      # disable after 2021-11-30 23:55
      # convert -resize 50% app/assets/images/globals/events/special_menu_1@2x.png app/assets/images/globals/events/special_menu_1.png
      Types::Ad::Type[:special_x300] => {
        provider: Types::Ad::Provider[:special],
        url: 'https://bit.ly/3mU0bP2',
        # pixel: 'https://ads.adfox.ru/211055/getCode?p1=coadb&p2=frfe&pfc=dtxhs&pfb=kgouc&pr=[RANDOM]&ptrc=b',
        images: (1..2).map do |i|
          {
            src: "/assets/globals/events/special_menu_#{i}.jpg",
            src_2x: "/assets/globals/events/special_menu_#{i}@2x.jpg"
          }
        end,
        rules: {
          cookie: 'i1',
          shows_per_week: 540 # 380
        },
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      # disable after 2021-11-30 23:55
      # convert -resize 50% app/assets/images/globals/events/special_wide_1@2x.png app/assets/images/globals/events/special_wide_1.png
      Types::Ad::Type[:special_x1170] => {
        provider: Types::Ad::Provider[:special],
        url: 'https://bit.ly/3mU0bP2',
        # pixel: 'https://ads.adfox.ru/211055/getCode?p1=coadb&p2=frfe&pfc=dtxhs&pfb=kgouc&pr=[RANDOM]&ptrc=b',
        images: (1..3).map do |i|
          {
            src: "/assets/globals/events/special_wide_#{i}.jpg",
            src_2x: "/assets/globals/events/special_wide_#{i}@2x.jpg"
          }
        end,
        # html: (
        #   <<~HTML
        #     <style>
        #       #iframe_special_x1170 {
        #         max-width: 1150px;
        #         width: 100%;
        #         height: 180px;
        #         margin: 0 auto;
        #         overflow: hidden;
        #       }
        #       .spns_special_x1170 {
        #         max-width: 1150px;
        #         margin: 0 auto;
        #         overflow: hidden;
        #       }
        #       .b-spns-special_x1170 {
        #         margin: 0 auto 45px;
        #         overflow: hidden;
        #       }
        #     </style>
        #     <iframe id="iframe_special_x1170" src="/1150x180Dogs.html">
        #   HTML
        # ),
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_300x250] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '491744',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_240x400] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '491736',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_300x600] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '491732',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_970x250] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '491748',
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_728x90] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '491746',
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_footer_300x250] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '457333',
        placement: Types::Ad::Placement[:footer],
        platform: Types::Ad::Platform[:mobile]
      },
      Types::Ad::Type[:yd_300x600] => {
        provider: Types::Ad::Provider[:yandex_direct],
        yandex_id: 'R-A-438288-1',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:yd_240x600] => {
        provider: Types::Ad::Provider[:yandex_direct],
        yandex_id: 'R-A-438288-2',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:yd_970x250] => {
        provider: Types::Ad::Provider[:yandex_direct],
        yandex_id: 'R-A-438288-3',
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:yd_970x90] => {
        provider: Types::Ad::Provider[:yandex_direct],
        yandex_id: 'R-A-438288-4',
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      }
    },
    false => {
      # disable after 2021-11-30 23:55
      Types::Ad::Type[:special_x300] => {
        provider: Types::Ad::Provider[:special],
        url: 'https://bit.ly/3mU0bP2',
        # pixel: 'https://ads.adfox.ru/211055/getCode?p1=coadb&p2=frfe&pfc=dtxhs&pfb=kgouc&pr=[RANDOM]&ptrc=b',
        images: (1..1).map do |i|
          {
            src: "/assets/globals/events/special_menu_#{i}.jpg",
            src_2x: "/assets/globals/events/special_menu_#{i}@2x.jpg"
          }
        end,
        rules: {
          cookie: 'i1',
          shows_per_week: 540 # 380
        },
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      # disable after 2021-11-30 23:55
      Types::Ad::Type[:special_x1170] => {
        provider: Types::Ad::Provider[:special],
        url: 'https://bit.ly/3mU0bP2',
        # pixel: 'https://ads.adfox.ru/211055/getCode?p1=coadb&p2=frfe&pfc=dtxhs&pfb=kgouc&pr=[RANDOM]&ptrc=b',
        images: (1..1).map do |i|
          {
            src: "/assets/globals/events/special_wide_#{i}.jpg",
            src_2x: "/assets/globals/events/special_wide_#{i}@2x.jpg"
          }
        end,
        # html: (
        #   <<~HTML
        #     <style>
        #       #iframe_special_x1170 {
        #         max-width: 1150px;
        #         width: 100%;
        #         height: 180px;
        #         margin: 0 auto;
        #         overflow: hidden;
        #       }
        #       .spns_special_x1170 {
        #         max-width: 1150px;
        #         margin: 0 auto;
        #         overflow: hidden;
        #       }
        #       .b-spns-special_x1170 {
        #         margin: 0 auto 45px;
        #         overflow: hidden;
        #       }
        #     </style>
        #     <iframe id="iframe_special_x1170" src="/1150x180Dogs.html">
        #   HTML
        # ),
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:advrtr_x728] => {
        provider: Types::Ad::Provider[:advertur],
        advertur_id: 92_445,
        width: 728,
        height: 90,
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:advrtr_240x400] => {
        provider: Types::Ad::Provider[:advertur],
        advertur_id: 92_129,
        width: 240,
        height: 400,
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:advrtr_300x250] => {
        provider: Types::Ad::Provider[:advertur],
        advertur_id: 92_485,
        width: 300,
        height: 250,
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_300x250] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '239817',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_240x400] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '239815',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_300x600] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '239819',
        placement: Types::Ad::Placement[:menu],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_728x90] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '239978',
        placement: Types::Ad::Placement[:content],
        platform: Types::Ad::Platform[:desktop]
      },
      Types::Ad::Type[:mt_footer_300x250] => {
        provider: Types::Ad::Provider[:mytarget],
        mytarget_id: '99457',
        placement: Types::Ad::Placement[:footer],
        platform: Types::Ad::Platform[:mobile]
      }
    }
  }

  META_TYPES = {
    true => {
      Types::Ad::Meta[:menu_300x250] => [
        Types::Ad::Type[:mt_300x250]
      ],
      Types::Ad::Meta[:menu_240x400] => [
        Types::Ad::Type[:special_x300], # 2021-11-30 23:55
        Types::Ad::Type[:yd_240x600],
        Types::Ad::Type[:mt_240x400]
      ],
      Types::Ad::Meta[:menu_300x600] => [
        Types::Ad::Type[:special_x300], # 2021-11-30 23:55
        Types::Ad::Type[:yd_300x600],
        Types::Ad::Type[:mt_300x600]
      ],
      Types::Ad::Meta[:horizontal_x250] => [
        Types::Ad::Type[:yd_970x250],
        Types::Ad::Type[:mt_970x250]
      ],
      Types::Ad::Meta[:horizontal_x90] => [
        Types::Ad::Type[:yd_970x90],
        Types::Ad::Type[:mt_728x90]
      ],
      Types::Ad::Meta[:footer] => [
        Types::Ad::Type[:mt_footer_300x250]
      ],
      Types::Ad::Meta[:special_x1170] => [
        Types::Ad::Type[:special_x1170], # 2021-11-30 23:55
        Types::Ad::Type[:yd_970x250],
        Types::Ad::Type[:mt_970x250]
      ]
    },
    false => {
      Types::Ad::Meta[:menu_300x250] => [
        # Types::Ad::Type[:mt_300x250],
        # Types::Ad::Type[:yd_240x400],
        Types::Ad::Type[:advrtr_240x400]
      ],
      Types::Ad::Meta[:menu_240x400] => [
        Types::Ad::Type[:special_x300], # 2021-11-30 23:55
        # Types::Ad::Type[:mt_240x400],
        # Types::Ad::Type[:yd_240x500],
        Types::Ad::Type[:advrtr_240x400]
      ],
      Types::Ad::Meta[:menu_300x600] => [
        Types::Ad::Type[:special_x300], # 2021-11-30 23:55
        # Types::Ad::Type[:mt_300x600],
        # Types::Ad::Type[:yd_300x600],
        # Types::Ad::Type[:advrtr_240x400],
        Types::Ad::Type[:advrtr_300x250]
      ],
      Types::Ad::Meta[:horizontal_x250] => [
        Types::Ad::Type[:advrtr_x728]
      ],
      Types::Ad::Meta[:horizontal_x90] => [
        # Types::Ad::Type[:mt_728x90],
        Types::Ad::Type[:advrtr_x728]
      ],
      Types::Ad::Meta[:footer] => [
        Types::Ad::Type[:mt_footer_300x250]
      ],
      Types::Ad::Meta[:special_x1170] => [
        Types::Ad::Type[:special_x1170] # 2021-11-30 23:55
      ]
    }
  }
end
