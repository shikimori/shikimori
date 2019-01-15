class Tags::CleanupIgnoredCoubTags
  method_object

  def call
    scope.find_each do |anime|
      new_tags = anime.coub_tags - config.ignored_tags

      anime.update!(
        coub_tags: new_tags,
        desynced: new_tags.any? ? anime.desynced : anime.desynced - %w[coub_tags]
      )
    end
  end

private

  def scope
    Anime.where("coub_tags @> '{\"#{config.ignored_tags.join('","')}\"}'")
  end

  def config
    @config ||= Tags::CoubConfig.new
  end
end
