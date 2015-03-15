class LstParser
  def parse text
    text
      .strip
      .split(/[\n\r]+---[\n\r]+/)
      .map do |group|
        group.strip.split(/[\r\n]+/)
      end
  end
end
