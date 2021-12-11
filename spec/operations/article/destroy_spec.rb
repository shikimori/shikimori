describe Article::Destroy do
  subject { described_class.call article, user }
  let!(:article) { create :article }

  it do
    expect { subject }.to change(Article, :count).by(-1)
    expect { article.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
