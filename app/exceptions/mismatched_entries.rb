class MismatchedEntries < Exception
  def initialize unmatched, ambiguous, twice_matched
    messages = []
    messages << "unmatched: #{unmatched.join ', '}" if unmatched.any?
    messages << "ambiguous: #{ambiguous.join ', '}" if ambiguous.any?
    messages << "twice matched: #{twice_matched.join ', '}" if twice_matched.any?
    super messages.join('; ')
  end
end
