# debian:
#   sudo apt-get install geoip-database geoip-database-contrib geoip-bin
# osx:
#   brew install geoip geoipupdate
#   geoipupdate

class GeoipAccess
  include Singleton

  # User.pluck(:last_sign_in_ip).uniq.map {|v| %x{geoiplookup #{v}}.fix_encoding[/GeoIP Country Edition: .*/] }.group_by {|v| v }.sort_by {|k,v| v.size }.each_with_object({}) {|(k,v),memo| memo[k] = v.size }
  SNG_COUNTRIES = Set.new [
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
    'LT', # Lithuania
    'RO', # Romania
    'TJ' # Tajikistan
  ]
  HZ = 'hz'

  def sng? ip
    SNG_COUNTRIES.include? country_code(ip)
  end

  def safe_ip ip
    ip.fix_encoding.gsub(/[^.\d]/, '')
  end

  def country_code ip
    safed_ip = safe_ip(ip)
    @codes ||= {}

    if @codes.include? safed_ip
      @codes[safed_ip]
    else
      @codes[safed_ip] = Rails.cache.fetch([:geo_ip, safed_ip, :v3]) do
        ask_geoip safed_ip
      end
    end
  end

private

  def ask_geoip ip
    result = `geoiplookup #{ip}`.fix_encoding

    result[/GeoIP Country Edition: (\w+)/, 1] ||
      result[/GeoIP City Edition(?:, Rev \d+)?: (\w+)/, 1] ||
      HZ
  end
end
