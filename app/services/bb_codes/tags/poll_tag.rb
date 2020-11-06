class BbCodes::Tags::PollTag
  include Singleton

  REGEXP = /
    \[poll=(\d+)\] \n?
  /mix

  def format text
    text.gsub(
      REGEXP,
      '<div class="poll-placeholder" id="\1" '\
        'data-track_poll="\1"></div>'
    )
  end
end
