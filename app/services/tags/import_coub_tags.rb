class Tags::ImportCoubTags
  TAGS_URL = 'http://coub.com/tags/list.txt.gz'
  LOCAL_GZ_PATH = '/tmp/list.txt.gz'
  LOCAL_PATH = '/tmp/list.txt'

  BATCH_SIZE = 5000

  method_object

  def call &block
    download
    ungzip

    new_tags = uniq_tags(read_lines)
    import_batches new_tags, &block

    new_tags
  end

private

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

  def uniq_tags tags
    log "found #{tags.size} tags"
    tags - CoubTag.pluck(:name)
  end

  def build_tags tags
    tags.map do |tag|
      CoubTag.new name: tag
    end
  end

  def read_lines
    File.open(LOCAL_PATH).read.split("\n")
  end

  def ungzip
    log "ungzipping #{LOCAL_GZ_PATH} into #{LOCAL_PATH}"
    `gzip -d #{LOCAL_GZ_PATH} -k -N -f`
  end

  def download
    log "downloading #{TAGS_URL} to #{LOCAL_GZ_PATH}"
    `wget '#{TAGS_URL}' -P '/tmp' -q -O '#{LOCAL_GZ_PATH}'`
  end

  def log text
    NamedLogger.coub.info text
  end
end
