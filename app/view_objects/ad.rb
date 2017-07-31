class Ad < ViewObjectBase
  # present advertur blocks
  # block_1: [92_129, 2_731],
  # block_2: [92_445, 1_256],
  # block_3: [92_485, nil]

  BANNERS = {
    advrtr_728x90: {
      provider: Types::Ad::Provider[:advertur],
      advertur_id: 1_256,
      width: 728,
      height: 90
    },
    advrtr_240x400: {
      provider: Types::Ad::Provider[:advertur],
      advertur_id: 2_731,
      width: 240,
      height: 400
    },
    yd_horizontal_poster_2x: {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-4'
    },
    yd_240x400: {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-2'
    },
    yd_wo_fallback: {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: nil
    }
  }
  FALLBACKS = {
    yd_horizontal_poster_2x: :advrtr_240x400,
    yd_240x400: :advrtr_240x400
  }

  attr_reader :banner_type, :policy
  delegate :allowed?, to: :policy

  def initialize banner_type
    @banner_type = banner_type
    @policy = build_policy

    if !@policy.allowed? && FALLBACKS[@banner_type]
      @banner_type = FALLBACKS[banner_type]
      @policy = build_policy
    end
  end

  def provider
    banner[:provider]
  end

  def ad_params
    return unless yandex_direct?

    {
      blockId: @banner_type,
      renderTo: @banner_type,
      async: true
    }
  end

  def css_class
    # if yandex_direct?
      # "spnsrs_#{@banner_type}"
    # else
      # "spnsrs_#{@banner_type}_#{banner[:width]}x#{banner[:height]}"
    # end

    "spnsrs_#{@banner_type}"
  end

  def to_html
    <<-HTML.gsub(/\n|^\ +/, '')
      <div class="b-spnsrs-#{@banner_type}">
        <center>
          #{ad_html}
        </center>
      </div>
    HTML
  end

private

  def build_policy
    AdsPolicy.new(
      is_ru_host: h.ru_host?,
      is_shikimori: h.shikimori?,
      ad_provider: provider,
      user_id: h.current_user&.id
    )
  end

  def banner
    BANNERS[@banner_type]
  end

  def yandex_direct?
    provider == Types::Ad::Provider[:yandex_direct]
  end

  def ad_html
    if yandex_direct?
      "<div id='#{@banner_type}'></div>"
    else
      "<iframe src='#{advertur_url}' width='#{banner[:width]}px' "\
        "height='#{banner[:height]}px'>"
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
end
