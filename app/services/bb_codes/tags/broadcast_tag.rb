class BbCodes::Tags::BroadcastTag
  include Singleton

  REGEXP = /
    \[broadcast\]
  /mix

  def format text
    text.gsub(REGEXP, '\1').strip
  end
end
