describe Forums::List do
  include_context :seeds
  include_context :view_object_warden_stub

  let(:user) { seed :user }
  let(:view) { Forums::List.new with_forum_size: with_forum_size }
  let(:with_forum_size) { false }

  describe '#to_a' do
    let(:with_forum_size) { true }
    it { expect(view.to_a).to have_at_least(5).items }
  end
end
