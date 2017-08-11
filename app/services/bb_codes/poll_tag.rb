class BbCodes::PollTag
  include Singleton

  REGEXP = %r{
    \[poll=(\d+)\]
  }mix

  def format text
    text.gsub REGEXP, '<div data-track_poll="\1"></div>'
  end
end
