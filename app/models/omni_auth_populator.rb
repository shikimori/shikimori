module OmniAuthPopulator
  def omniauth=(omni)
    if omni['provider'] && respond_to?('populate_from_' + omni['provider'])
      send(('populate_from_' + omni['provider']).to_sym, omni)
    end
  end

  def fast_token
    values = [
      rand(0x0010000),
      rand(0x0010000),
      rand(0x0010000),
      rand(0x0010000),
      rand(0x0010000),
      rand(0x1000000),
      rand(0x1000000),
    ]
    "%04x%04x%04x%04x%04x%06x%06x" % values
  end
end
