# how to get most common words
=begin
def take_uniq tags, limit
  tags.
    each_with_object({}) { |word, memo| memo[word] ||= 0; memo[word] += 1 }.
    sort_by { |k,v| -v }.
    take(limit).
    map(&:first)
end

def franchises
  @franchises ||= Set.new(
    Anime.pluck(Arel.sql('distinct(franchise)')).select(&:present?)
  )
end

raw_tags = File.open(Tags::ImportCoubTags::LOCAL_PATH).
  read.
  split("\n");

tags = raw_tags.
  flat_map { |v| v.split(' ') }.
  map { |v| v.gsub(/[^\wА-я]+/, '') }.
  select { |v| v.size > 0 && v.size <= 40 }.
  reject { |v| v.match? /^\d+$/ };

tags.select { |v| franchises.include? v }.uniq.each { |v| puts "found franchise: #{v}" };
tags = tags.reject { |v| franchises.include? v }

limit = 2000
top_en_tags = take_uniq(tags.select { |v| v.match? /[A-z]/ }, limit);
top_ru_tags = take_uniq(tags.select { |v| v.match? /[А-я]/ }, limit);

config = YAML.load_file(Rails.root.join(Tags::CoubConfig::CONFIG_PATH));
config[:ignored_auto_generated] = top_en_tags + top_ru_tags;

File.open(Rails.root.join(Tags::CoubConfig::CONFIG_PATH), 'w') do |f|
  f.write config.to_yaml
end
=end
class Tags::ImportCoubTags # rubocop:disable ClassLength
  TAGS_URL = 'http://coub.com/tags/list.txt.gz'
  LOCAL_GZ_PATH = '/tmp/list.txt.gz'
  LOCAL_PATH = '/tmp/list.txt'

  MAXIMUM_TAG_SIZE = 40
  MINIMUM_TAG_SIZE = 4

  BATCH_SIZE = 5000

  method_object

  def call &block
    download
    ungzip

    new_tags = process read_tags
    import_batches new_tags, &block

    new_tags
  end

private

  def process tags
    exclude_single_words(
      exclude_large(
        exclude_small(
          exclude_ignored(
            take_new(tags)
          )
        )
      )
    )
  end

  def import_batches new_tags, &block
    log "importing #{new_tags.size} tags"

    new_tags.each_slice(BATCH_SIZE) do |tags|
      import_batch tags, &block
      log "imported batch of #{tags.size} tags"
    end
  end

  def import_batch tags, &_block
    CoubTag.transaction do
      CoubTag.import build_tags(tags), on_duplicate_key_ignore: true
      yield tags if block_given?
    end
  end

  def exclude_single_words tags
    new_tags = tags.select { |tag| tag.match?(/[ _]/) || franchises.include?(tag) }
    log "-#{tags.size - new_tags.size} single words"
    new_tags
  end

  def exclude_large tags
    new_tags = tags.reject { |v| v.size > MAXIMUM_TAG_SIZE }
    log "-#{tags.size - new_tags.size} large tags"
    new_tags
  end

  def exclude_small tags
    new_tags = tags.reject { |v| v.size < MINIMUM_TAG_SIZE }
    log "-#{tags.size - new_tags.size} small tags"
    new_tags
  end

  def exclude_ignored tags
    new_tags = tags - ignored_tags
    log "-#{tags.size - new_tags.size} ignored tags"
    new_tags
  end

  def take_new tags
    new_tags = tags - CoubTag.pluck(:name)
    log "#{new_tags.size} new tags"
    new_tags
  end

  def build_tags tags
    tags.map do |tag|
      CoubTag.new name: tag
    end
  end

  def read_tags
    log "reading tags from #{LOCAL_PATH}"
    tags = File.open(LOCAL_PATH).read.split("\n")
    log "#{tags.size} tags found"
    tags
  end

  def ungzip
    log "ungzipping #{LOCAL_GZ_PATH} into #{LOCAL_PATH}"

    if Rails.env.production? || !File.exist?(LOCAL_PATH)
      `gzip -d #{LOCAL_GZ_PATH} -k -N -f`
    end
  end

  def download
    log "downloading #{TAGS_URL} to #{LOCAL_GZ_PATH}"

    if Rails.env.production? || !File.exist?(LOCAL_GZ_PATH)
      `wget '#{TAGS_URL}' -P '/tmp' -q -O '#{LOCAL_GZ_PATH}'`
    end
  end

  def franchises
    @franchises ||= Set.new(
      Anime.pluck(Arel.sql('distinct(franchise)')).select(&:present?)
    )
  end

  def log text
    NamedLogger.coub.info text
  end

  def ignored_tags
    config.ignored_tags + config.ignored_auto_generated
  end

  def config
    @config ||= Tags::CoubConfig.new
  end
end
