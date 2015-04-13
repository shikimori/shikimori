class BbCodes::ColorTag
  include Singleton

  def format text
    text.gsub(
      /\[color=(\#[\da-f]+|\w+)\] ([\s\S]*?) \[\/color\]/mix,
      '<span style="color: \1;">\2</span>')
  end
end
