class ImportPeopleJob < JobWithRestart
  def do
    PersonMalParser.import
  end
end
