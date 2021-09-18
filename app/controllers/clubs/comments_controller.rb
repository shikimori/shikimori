class Clubs::CommentsController < ClubsController
  def broadcast
    authorize! :broadcast, @resource.object
    og page_title: t('clubs.actions.broadcast')

    @new_comment = @resource.preview_topic_view.comments_view.new_comment
  end
end
