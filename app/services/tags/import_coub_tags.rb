class Tags::ImportCoubTags
  TAGS_URL = 'http://coub.com/tags/list.txt.gz'
  LOCAL_GZ_PATH = '/tmp/list.txt.gz'
  LOCAL_PATH = '/tmp/list.txt'

  CONFIG_PATH = 'config/app/coub_tags.yml'

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
    log "new tags found: #{new_tags.size}"
    new_tags
  end

  def build_tags tags
    tags.map do |tag|
      CoubTag.new name: tag
    end
  end

  def read_tags
    File.open(LOCAL_PATH).read.split("\n")
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
    @franchises ||= Set.new Anime.pluck('distinct(franchise)').select(&:present?)
  end

  def log text
    NamedLogger.coub.info text
  end

  def ignored_tags
    config[:ignored_tags]
  end

  def config
    @config ||= YAML.load_file(Rails.root.join(CONFIG_PATH))
  end
end
