class Animes::BannedFranchiseNames
  include Singleton
  include Enumerable

  CONFIG_PATH = "#{Rails.root}/config/app/banned_franchise_names.yml"

  def each
    banned_names.each { |v| yield v }
  end

private

  def banned_names
    YAML.load_file CONFIG_PATH
  end
end
