class IgnoresController < ShikimoriController
  before_action :authenticate_user!

  def create
    ignores = (params[:user_ids] || []).uniq.map do |user_id|
      Ignore.new user: current_user, target_id: user_id
    end

    Ignore.import ignores, on_duplicate_key_ignore: true

    redirect_back fallback_location: fallback_url
  end

private

  def fallback_url
    edit_profile_url current_user, section: 'ignored_topics'
  end
end
