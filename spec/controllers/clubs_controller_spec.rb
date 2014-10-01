require 'spec_helper'

describe ClubsController do
  let(:club) { create :group }

  describe :index do
    let(:club) { create :group, :with_thread }
    let(:user) { create :user }
    let!(:group_role) { create :group_role, group: club, user: user, role: 'admin' }

    describe :no_pagination do
      before { get :index }
      it { should respond_with :success }
      it { expect(assigns :collection).to eq [club] }
    end

    describe :pagination do
      before { get :index, page: 1 }
      it { should respond_with :success }
    end
  end

  describe :show do
    let(:club) { create :group, :with_thread }
    before { get :show, id: club.to_param }
    it { should respond_with :success }
  end

  describe :new do
    include_context :authenticated
    before { get :new }
    it { should respond_with :success }
  end

  describe :edit do
    include_context :authenticated
    before { get :new }
    it { should respond_with :success }
  end

  #describe :edit do
    #before { sign_in user }
    #before { get :edit, id: club.to_param }
    #it { should respond_with :success }
  #end

  describe :members do
    let(:club) { create :group }
    before { get :members, id: club.to_param }
    it { should respond_with :success }
  end

  describe :comments do
    let!(:club) { create :group, :with_thread }

    context :without_comments do
      before { get :comments, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context :with_comments do
      let!(:comment) { create :comment, commentable: club.thread }
      before { club.thread.update comments_count: 1 }
      before { get :comments, id: club.to_param }
      it { should respond_with :success }
    end
  end

  describe :animes do
    context :without_animes do
      before { get :animes, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context :with_animes do
      let(:club) { create :group, :with_thread, :linked_anime }
      before { get :animes, id: club.to_param }
      it { should respond_with :success }
    end
  end

  describe :mangas do
    context :without_mangas do
      before { get :mangas, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context :with_mangas do
      let(:club) { create :group, :with_thread, :linked_manga }
      before { get :mangas, id: club.to_param }
      it { should respond_with :success }
    end
  end

  describe :characters do
    context :without_characters do
      before { get :characters, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context :with_characters do
      let(:club) { create :group, :with_thread, :linked_character }
      before { get :characters, id: club.to_param }
      it { should respond_with :success }
    end
  end
end
