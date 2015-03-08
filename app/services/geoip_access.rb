# debian:
#   sudo apt-get install geoip-database geoip-database-contrib geoip-bin
# osx:
#   brew install geoip geoipupdate
#   geoipupdate

class GeoipAccess
  pattr_initialize :ip

  # User.pluck(:last_sign_in_ip).uniq.map {|v| %x{geoiplookup #{v}}.fix_encoding[/GeoIP Country Edition: .*/] }.group_by {|v| v }.sort_by {|k,v| v.size }.each_with_object({}) {|(k,v),memo| memo[k] = v.size }
  ALLOWED_COUNTRIES = Set.new([
    'RU', # Russian Federation
    'UA', # Ukraine
    'BY', # Belarus
    'KZ', # Kazakhstan
    'MD', # Moldova
    'LV', # Latvia
    'AZ', # Azerbaijan
    'EE', # Estonia
    'KG', # Kyrgyzstan
    'UZ', # Uzbekistan
    'IL', # Israel
    'LT', # Lithuania
    'RO', # Romania
    'TJ', # Tajikistan
  ])

  def allowed?
    _stub_test || ALLOWED_COUNTRIES.include?(country_code)
  end

  def safe_ip
    @safe_ip ||= ip.fix_encoding.gsub(/[^.\d]/, '')
  end

  def country_code
    @country_code ||= Rails.cache.fetch([:geo_ip, safe_ip]) { ask_geoip safe_ip }
  end

private
  def ask_geoip ip
    %x{geoiplookup #{ip}}
      .fix_encoding[/GeoIP Country Edition: (\w+)/, 1] || 'hz'
  end

  # специальная заглушка, чтобы в тестах не выполнялось
  def _stub_test
    true if Rails.env.test? || Rails.env.development?
  end
end
