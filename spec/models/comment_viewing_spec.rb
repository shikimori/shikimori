describe CommentViewing do
  it do
    is_expected.to belong_to :user
    is_expected.to belong_to(:viewed)
      .class_name(Comment.name)
      .with_foreign_key(:viewed_id)
  end
end
