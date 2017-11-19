class VideoExtractor::CleanupParams
  method_object :url, :allowed_params

  def call
    @url
      .gsub('&amp;', '&')
      .gsub(/[?&](?<param>[^=]+)$/, '')
      .gsub(/(?<=[?&])(?<param>[^=]+)=[^&]*(?:&|$)/) do |match|
        @allowed_params.include?($LAST_MATCH_INFO[:param]) ? match : ''
      end
      .gsub(/&$/, '')
  end
end
