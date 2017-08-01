class MismatchedEntries < ArgumentError
  def initialize unmatched, ambiguous, twice_matched
    messages = []
    messages << "unmatched:\n#{unmatched.join "\n"}\n" if unmatched.any?
    messages << "ambiguous:\n#{ambiguous.join "\n"}\n" if ambiguous.any?
    messages << "twice matched:\n#{twice_matched.join "\n"}\n" if twice_matched.any?
    super messages.join("\n")
  end
end
