class Tags::CleanupIgnoredCoubTags
  method_object

  def call
    scope.find_each do |anime|
      anime.update!(
        coub_tag: nil,
        desynced: anime.desynced - %w[coub_tag]
      )
    end
  end

private

  def scope
    Anime.where(coub_tag: config.ignored_tags)
  end

  def config
    @config ||= Tags::CoubConfig.new
  end
end
