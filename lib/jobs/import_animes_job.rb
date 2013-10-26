class ImportAnimesJob < JobWithRestart
  def do
    AnimeMalParser.import
  end
end
