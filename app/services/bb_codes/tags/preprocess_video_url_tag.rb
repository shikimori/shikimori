class BbCodes::Tags::PreprocessVideoUrlTag
  include Singleton

  VIDEO_REGEXP = %r{
    (?<! = | =http: | =https: )
    (?<url_prefix> \[url (?:= (?: [^\]]+? ) )? \] )?
    (?<url> #{VideoExtractor.matcher} )
    (?<url_suffix> \[/url\] )?
  }mix

  def format text
    text.gsub VIDEO_REGEXP do |match|
      url = $LAST_MATCH_INFO[:url]
      url_prefix = $LAST_MATCH_INFO[:url_prefix]
      url_suffix = $LAST_MATCH_INFO[:url_suffix]

      if url_prefix.present? && url_suffix.present?
        match
      else
        "[video]#{url}[/video]"
      end
    end
  end
end
