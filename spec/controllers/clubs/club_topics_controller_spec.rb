describe Clubs::ClubTopicsController do
  include_context :authenticated, :user
  # let(:club) { create :club, owner: user }
  # let(:club_page) { create :club_page, club: club }

  # describe '#new' do
    # before { get :new, params: { club_id: club.id, club_page: { club_id: club.id } } }
    # it { expect(response).to have_http_status :success }
  # end

  # describe '#create' do
    # before { post :create, params: { club_id: club.id, club_page: params } }

    # context 'success' do
      # let(:params) do
        # {
          # club_id: club.id,
          # parent_page_id: nil,
          # name: 'test',
          # text: 'zxc',
          # layout: 'menu'
        # }
      # end

      # it do
        # expect(resource).to be_persisted
        # expect(resource).to have_attributes(
          # club_id: params[:club_id],
          # parent_page_id: params[:parent_page_id],
          # name: params[:name],
          # text: params[:text]
        # )
        # expect(response).to redirect_to edit_club_club_page_path(club, resource)
      # end
    # end

    # context 'failure' do
      # let(:params) { { club_id: club.id, name: '', text: '' } }

      # it do
        # expect(resource).to_not be_persisted
        # expect(response).to render_template :form
      # end
    # end
  # end

  # describe '#edit' do
    # before { get :edit, params: { club_id: club.to_param, id: club_page.id } }
    # it { expect(response).to have_http_status :success }
  # end

  # describe '#update' do
    # before { patch :update, params: { club_id: club.id, id: club_page.id, club_page: params } }

    # context 'success' do
      # let(:params) do
        # {
          # club_id: club.id,
          # parent_page_id: nil,
          # name: 'test',
          # text: 'zxc',
          # layout: 'menu'
        # }
      # end

      # it do
        # expect(resource).to be_valid
        # expect(resource).to_not be_changed
        # expect(resource).to have_attributes(
          # club_id: params[:club_id],
          # parent_page_id: params[:parent_page_id],
          # name: params[:name],
          # text: params[:text]
        # )
        # expect(response).to redirect_to edit_club_club_page_path(club, resource)
      # end
    # end

    # context 'failure' do
      # let(:params) { { club_id: club.id, name: '', text: '' } }

      # it do
        # expect(resource).to be_changed
        # expect(resource).to_not be_valid
        # expect(response).to render_template :form
      # end
    # end
  # end

  # describe '#destroy' do
    # before { delete :destroy, params: { club_id: club.id, id: club_page.id } }

    # it do
      # expect(resource).to be_destroyed
      # expect(response).to redirect_to edit_club_url(club, page: :pages)
    # end
  # end

  # describe '#up' do
    # include_context :back_redirect
    # let!(:club_page) { create :club_page, club: club, position: 2 }
    # let!(:club_page_2) { create :club_page, club: club, position: 1 }

    # before { post :up, params: { club_id: club.id, id: club_page.id } }

    # it do
      # expect(club_page.reload.position).to eq 1
      # expect(club_page_2.reload.position).to eq 3
      # expect(response).to redirect_to back_url
    # end
  # end

  # describe '#down' do
    # include_context :back_redirect

    # let!(:club_page) { create :club_page, club: club, position: 1 }
    # let!(:club_page_2) { create :club_page, club: club, position: 2 }

    # before { post :down, params: { club_id: club.id, id: club_page.id } }

    # it do
      # expect(club_page.reload.position).to eq 2
      # expect(club_page_2.reload.position).to eq 1
      # expect(response).to redirect_to back_url
    # end
  # end
end
