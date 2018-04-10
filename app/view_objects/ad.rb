# rubocop:disable ClassLength
class Ad < ViewObjectBase
  # present advertur blocks
  # block_1: [92_129, 2_731],
  # block_2: [92_445, 1_256],
  # block_3: [92_485, nil]

  BANNERS = {
    special_x300: {
      provider: Types::Ad::Provider[:special],
      url: 'https://panzer.kg-portal.ru',
      images: (1..1).map do |i|
        {
          src: "/assets/globals/events/special_#{i}.jpg",
          src_2x: "/assets/globals/events/special_#{i}@2x.jpg"
        }
      end,
      # rules: {
      #   cookie: 'i2',
      #   shows_per_week: 30
      # },
      placement: Types::Ad::Placement[:menu]
    },
    admachina_x240: {
      provider: Types::Ad::Provider[:admachina],
      placement: Types::Ad::Placement[:menu],
      html: <<~HTML
        <div style="height:400px;width:240px"><div id="aa66f5a7eae"></div></div>
        <script>
            (function (w, d, s, e, i, u) {
                w[e] = w[e] || [];
                w[e].push({'admbnr.start': new Date().getTime(), event: 'load.js'});
                w[e].push({'admbnr.uid': i, event: 'load.js'});
                var f = d.getElementsByTagName(s)[0], j = d.createElement(s);
                j.async = true;
                j.src = 'https://admachina.com/bv2/load.js?uid=' + i.join('|');
                j.onerror = function () {
                    js = d.createElement(s);
                    js.async = true;
                    js.src = '/' + u + '.php?uid=' + i.join('|');
                    f.parentNode.insertBefore(js, f);
                };
                f.parentNode.insertBefore(j, f);
            })(window, document, 'script', 'admbnr', ['aa66f5a7eae'], 'a699842fb529382e40c5e563eb');
        </script>
      HTML
    },
    advrtr_x728: {
      provider: Types::Ad::Provider[:advertur],
      advertur_id: 1_256,
      width: 728,
      height: 90,
      placement: Types::Ad::Placement[:content]
    },
    advrtr_x240: {
      provider: Types::Ad::Provider[:advertur],
      advertur_id: 2_731,
      width: 240,
      height: 400,
      placement: Types::Ad::Placement[:menu]
    },
    yd_poster_x300_2x: {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-4',
      placement: Types::Ad::Placement[:menu]
    },
    yd_poster_x240_2x: {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-5',
      placement: Types::Ad::Placement[:menu]
    },
    yd_rtb_x240: {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-2',
      placement: Types::Ad::Placement[:menu]
    },
    yd_horizontal: {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-7',
      placement: Types::Ad::Placement[:content]
    }
  }
  FALLBACKS = {
    yd_poster_x300_2x: :advrtr_x240,
    yd_poster_x240_2x: :advrtr_x240,
    yd_rtb_x240: :advrtr_x240,
    yd_horizontal: :advrtr_x728,
    special_x300: :yd_rtb_x240
  }

  attr_reader :banner_type, :policy

  def initialize banner_type
    switch_banner banner_type

    switch_banner :yd_poster_x300_2x if yd_rtb_in_topics?
    switch_banner :yd_poster_x240_2x if yd_x300_body_x1000?
    switch_banner FALLBACKS[banner_type] if not_allowed_with_fallback?
  end

  def allowed?
    # # temporarily disable advertur
    # if provider == Types::Ad::Provider[:advertur] &&
        # h.params[:action] != 'advertur_test' && Rails.env.production? &&
        # h.current_user&.id != 1
      # return false
    # end

    if h.controller.instance_variable_get controller_key(banner[:placement])
      false
    else
      policy.allowed? && (!@rules || @rules.show?)
    end
  end

  def provider
    banner[:provider]
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
    "spnsrs_#{@banner_type}"
  end

  def to_html
    finalize

    <<-HTML.gsub(/\n|^\ +/, '')
      <div class="b-spnsrs-#{@banner_type}">
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
    @rules = build_rules if banner[:rules]
  end

  def build_policy
    AdsPolicy.new(
      user: h.current_user,
      ad_provider: provider,
      is_ru_host: h.ru_host?,
      is_shikimori: h.shikimori?,
      is_disabled: h.cookies["#{css_class}_disabled"].present?
    )
  end

  def build_rules
    Ads::Rules.new banner[:rules], h.cookies[banner[:rules][:cookie]]
  end

  def banner
    BANNERS[@banner_type]
  end

  def yandex_direct?
    provider == Types::Ad::Provider[:yandex_direct]
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

  def ad_html # rubocop:disable AbcSize, MethodLength, PerceivedComplexity
    if yandex_direct?
      "<div id='#{@banner_type}'></div>"
    elsif banner?
      image = banner[:images].sample

      image_html =
        if image[:src_2x]
          "<img src='#{image[:src]}' srcset='#{image[:src_2x]} 2x'>"
        else
          "<img src='#{image[:src]}'>"
        end

      "<a href='#{banner[:url]}'>#{image_html}</a>"
    elsif html?
      banner[:html]
    elsif iframe?
      "<iframe src='#{advertur_url}' width='#{banner[:width]}px' "\
        "height='#{banner[:height]}px'>"
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

  def yd_rtb_in_topics?
    @banner_type == :yd_rtb_x240 && h.params[:controller] == 'topics'
  end

  def yd_x300_body_x1000?
    @banner_type == :yd_poster_x300_2x &&
      h.current_user&.preferences&.body_width_x1000?
  end

  def not_allowed_with_fallback?
    !@policy.allowed? && FALLBACKS[@banner_type]
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
end
# rubocop:enable ClassLength
