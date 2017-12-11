# NOTE: deprecated. remove after final migration to chewy
# https://www.airpair.com/elasticsearch/posts/elasticsearch-robust-search-functionality#6-search-improvement
# version with icu requires analysis-icu plugin
#   bin/elasticsearch-plugin install analysis-icu
# https://gist.github.com/HuangFJ/6f3d4722782990ab7dc7
class Elasticsearch::Config
  include Singleton

  CONFIG_FILE = Rails.root.join('config/app/elasticsearch.yml')
  INDEX = :shikimori

  def [] key
    config[key]
  end

  def config
    @config ||= YAML.load_file CONFIG_FILE
  end
end
