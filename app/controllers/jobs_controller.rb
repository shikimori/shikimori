class JobsController < ApplicationController
  def restart
    raise Forbidden unless user_signed_in? && current_user.admin?
    job = Delayed::Job.find(params[:id].to_i)
    job.update_attributes({
      locked_at: nil,
      failed_at: nil,
      locked_by: nil,
      attempts: 0
    })
    job.update_attribute :last_error, nil
    redirect_to :back
  end
end
