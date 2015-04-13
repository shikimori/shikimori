class BbCodes::SizeTag
  include Singleton

  def format text
    text.gsub(
      /\[size=(\d+)\] ([\s\S]*?) \[\/size\]/mix,
      '<span style="font-size: \1px;">\2</span>')
  end
end
