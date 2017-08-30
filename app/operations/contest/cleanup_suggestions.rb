class Contest::CleanupSuggestions
  method_object :contest

  def call
    @contest.suggestions
      .joins(:user)
      .merge(User.suspicious)
      .destroy_all
  end
end
