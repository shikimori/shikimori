class BbCodes::Tags::VideoUrlTag
  include Singleton

  VIDEO_REGEXP = %r{
    (?<! = | =http: | =https: )
    (?<url_prefix>
      \[(?<tag>url) (?:= (?: [^\]]+? ) )? \] | \[(?<tag>video)\]
    )?
    (?<url> #{VideoExtractor.matcher} )
    (?<url_suffix> \[/\k<tag>\] )?
  }ix

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
