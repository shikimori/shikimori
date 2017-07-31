class Ad < ViewObjectBase
  vattr_initialize :width, :height

  ADVERTUR_IDS = {
    block_1: [92_129, 2_731],
    block_2: [92_445, 1_256],
    block_3: [92_485, nil]
  }

  ERROR = 'unknown ad size'

  def allowed?
    !moderator_ids.include? h.current_user&.id
  end

  def html
    <<~HTML.strip
      <div class="b-spnsrs_#{block_key}">
      <center>
      #{ad_html}
      </center>
      </div>
    HTML
  end

  def container_class
    "spnsrs_#{ad_id}_#{@width}_#{@height}"
  end

  def params
    {
      blockId: 'R-A-227837-2',
      renderTo: yandex_direct_id,
      async: true
    }
  end

  def type
    if yandex_direct?
      :yandex_direct
    else
      :advertur
    end
  end

  def yandex_direct?
    h.ru_host? && h.shikimori? && block_key == :block_1# &&
      # !Rails.env.development? && h.current_user&.id == 1
  end

private

  def ad_id
    if yandex_direct?
      yandex_direct_id
    else
      advertur_id
    end
  end

  def yandex_direct_ad
    "<div id='#{yandex_direct_id}'></div>"
  end

  def ad_html
    if yandex_direct?
      yandex_direct_ad
    else
      advertur_ad
    end
  end

  def advertur_ad
    "<iframe src='#{advertur_url}' width='#{width}px' height='#{height}px'>"
  end

  # rubocop:disable CyclomaticComplexity
  def block_key
    return :block_1 if @width == 240 && @height == 400
    return :block_2 if @width == 728 && @height == 90
    return :block_3 if @width == 300 && @height == 250

    raise ArgumentError, ERROR
  end
  # rubocop:enable CyclomaticComplexity

  def domain_key
    h.shikimori? ? 0 : 1
  end

  def moderator_ids
    (
      User::MODERATORS + User::REVIEWS_MODERATORS + User::VERSIONS_MODERATORS +
      User::VIDEO_MODERATORS + User::TRUSTED_VERSION_CHANGERS +
      User::TRUSTED_VIDEO_UPLOADERS
    ).uniq - User::ADMINS
  end

  def advertur_url
    h.spnsr_url(
      advertur_id,
      width: @width,
      height: @height,
      container_class: container_class,
      protocol: false
    )
  end

  def advertur_id
    ADVERTUR_IDS.dig(block_key, domain_key) || raise(ArgumentError, ERROR)
  end

  def yandex_direct_id
    :block_1_yd
  end
end
