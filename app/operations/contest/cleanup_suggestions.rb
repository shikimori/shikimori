class Contest::CleanupSuggestions
  method_object :contest

  def call
    Rails.logger.info "Contest::CleanupSuggestions #{@contest.id}"

    @contest.suggestions
      .joins(:user)
      .merge(User.suspicious)
      .destroy_all
  end
end
