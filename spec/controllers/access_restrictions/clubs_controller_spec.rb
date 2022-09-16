describe ClubsController, type: :controller do
  subject do
    get :show, params: { id: club.to_param }
  end

  include_context :club_access_check
end
