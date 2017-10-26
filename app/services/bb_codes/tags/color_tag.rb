class BbCodes::Tags::ColorTag
  include Singleton

  def format text
    text.gsub(
      /\[color=(\#[\da-f]+|\w+)\] (.*?) \[\/color\]/mix,
      '<span style="color: \1;">\2</span>')
  end
end
