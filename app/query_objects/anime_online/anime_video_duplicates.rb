class AnimeOnline::AnimeVideoDuplicates
  method_object :url

  def call
    return [] if @url.blank?

    AnimeVideo
      .where(url: ["http:#{base_url}", "https:#{base_url}"])
      .where(state: [:working, :uploaded])
  end

private

  def base_url
    @base_url ||= Url.new(@url).without_protocol.to_s
  end
end
