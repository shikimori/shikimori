class BbCodes::Tags::VideoUrlTag
  include Singleton

  PREPROCESS_REGEXP = %r{
    \[url=(?<url> #{VideoExtractor.matcher} )\]
      .*?
    \[/url\]
  }mix
  VIDEO_REGEXP = /
    (?: \[url (?:=[^\]]+?)? \] )?
    (?<url> #{VideoExtractor.matcher} )
  /mix

  def format text
    text.gsub VIDEO_REGEXP do |match|
      next match if match.starts_with? '[url'

      "[video]#{$LAST_MATCH_INFO[:url]}[/video]"
    end
  end
end
