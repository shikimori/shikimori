class Clubs::CommentsController < ClubsController
  def broadcast
    authorize! :broadcast, @resource.object
    page_title t('clubs.actions.broadcast')
  end
end
