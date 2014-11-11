describe SimilarUsersService do
  let(:user) { create :user }

  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }

  before do
    allow_any_instance_of(SimilarUsersService).to receive(:similarities).and_return [
      [user1.id, 0.2],
      [user2.id, 0.7],
      [user3.id, 0.4]
    ]
  end

  subject { SimilarUsersService.new(user, Anime, 50).fetch }
  it { should eq [user2.id, user3.id, user1.id] }
end
