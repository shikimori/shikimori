class IgnoresController < ShikimoriController
  before_action :authenticate_user!

  def create
    ignores = (params[:user_ids] || []).map do |user_id|
      Ignore.new user: current_user, target_id: user_id
    end

    Ignore.import ignores, on_duplicate_key_ignore: true

    redirect_back(
      fallback_location: edit_profile_url(
        current_user, page: 'ignored_topics'
      )
    )
  end
end
