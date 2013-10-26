class ImportMangasJob < JobWithRestart
  def do
    MangaMalParser.import
  end
end
