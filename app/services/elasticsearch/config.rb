# https://www.airpair.com/elasticsearch/posts/elasticsearch-robust-search-functionality#6-search-improvement
# version with icu requires analysis-icu plugin
#   bin/elasticsearch-plugin install analysis-icu
# https://gist.github.com/HuangFJ/6f3d4722782990ab7dc7
class Elasticsearch::Config
  include Singleton

  CONFIG_FILE = Rails.root.join('config/app/elasticsearch.yml')

  def [] key
    config[key]
  end

private

  def config
    YAML.load_file CONFIG_FILE
  end
end
