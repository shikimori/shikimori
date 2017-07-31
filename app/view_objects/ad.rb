class Ad < ViewObjectBase
  vattr_initialize :width, :height

  ADVERTUR_IDS = {
    block_1: [92_129, 2_731],
    block_2: [92_445, 1_256],
    block_3: [92_485, nil]
  }

  def allowed?
    !moderator_ids.include? h.current_user&.id
  end

  def html
    <<-HTML
      <div class="b-spnsrs_#{block_key}">
        <center>
          #{ad_html}
        </center>
      </div>
    HTML
  end

private

  def yandex_direct_ad
    "<div id='#{yandex_direct_id}'></div>"
  end

  def ad_html
    if h.ru_host? && h.shikimori? && block_key == :block_1
      yandex_direct_ad
    else
      advertur_ad
    end
  end

  def advertur_ad
    "<iframe src='#{advertur_url}' width='#{width}px' height='#{height}px'>"
  end

  def block_key
    if @width == 240 && @height == 400
      :block_1
    elsif @width == 728 && @height == 90
      :block_2
    elsif @width == 300 && @height == 250
      :block_3
    end
  end

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
      container_class: advertur_class,
      protocol: false
    )
  end

  def advertur_id
    ADVERTUR_IDS.dig(block_key, domain_key) || fail('unknown ad')
  end

  def yandex_direct_id
    :block_1_yd
  end

  def advertur_class
    "spnsrs_#{advertur_id}_#{@width}_#{@height}"
  end
end
