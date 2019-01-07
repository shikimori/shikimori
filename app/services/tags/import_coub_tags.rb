class Tags::ImportCoubTags
  TAGS_URL = 'http://coub.com/tags/list.txt.gz'
  LOCAL_GZ_PATH = '/tmp/list.txt.gz'
  LOCAL_PATH = '/tmp/list.txt'

  method_object

  def call
    download
    ungzip
    import uniq_tags(read_lines)
  end

private

  def import new_tags
    log "importing #{new_tags.size} tags"

    new_tags.each_slice(5000) do |tags|
      batch = build_tags(tags)
      CoubTag.import batch, on_duplicate_key_ignore: true
      log "imported batch of #{batch.size} tags"
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
    # `gzip -d #{LOCAL_GZ_PATH} -k -N -f`
  end

  def download
    log "downloading #{TAGS_URL} to #{LOCAL_GZ_PATH}"
    # `wget '#{TAGS_URL}' -P '/tmp' -q -O '#{LOCAL_GZ_PATH}'`
  end

  def log text
    NamedLogger.coub.info text
  end
end
