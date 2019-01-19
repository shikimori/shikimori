class Tags::ImportCoubTags
  method_object :tags

  BATCH_SIZE = 5000

  def call
    import_batches take_new(@tags)
  end

private

  def take_new tags
    new_tags = tags - all_tags
    log "#{new_tags.size} new tags"
    new_tags
  end

  def all_tags
    CoubTag.pluck(:name)
  end

  def import_batches new_tags
    log "importing #{new_tags.size} tags"

    new_tags.each_slice(BATCH_SIZE) do |tags|
      import_batch tags
      log "imported batch of #{tags.size} tags"
    end
  end

  def import_batch tags
    CoubTag.import build_tags(tags), on_duplicate_key_ignore: true
  end

  def build_tags tags
    tags.map do |tag|
      CoubTag.new name: tag
    end
  end

  def log text
    NamedLogger.coub_tag.info text
  end
end
