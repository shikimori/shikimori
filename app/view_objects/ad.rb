class Ad < ViewObjectBase
  vattr_initialize :width, :height

  IDS = {
    block_1: [92129, 2731],
    block_2: [92445, 1256],
    block_3: [92485, nil]
  }

  def id
    IDS.dig(block_key, domain_key) || fail('unknown ad')
  end

  def url
    h.sponsor_url id, width: @width, height: @height, container_class: container_class
  end

  def container_class
    "sponsors_#{id}_#{@width}_#{@height}"
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

private

  def domain_key
    h.anime_online? ? 1 : 0
  end
end
