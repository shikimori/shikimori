describe CommentView, :type => :model do
  it { should belong_to :user }
  it { should belong_to :comment }
end
