# TODO: в groups_controller#show заюзать его
class GroupPresenter < BasePresenter
  proxy :name

  def url
    club_url(@object)
  end

  def image
    @object.logo
  end
end
