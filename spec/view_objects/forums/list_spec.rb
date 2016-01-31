describe Forums::List do
  include_context :seeds
  include_context :view_object_warden_stub

  let(:user) { seed :user }
  let(:view) { Forums::List.new }

  before do
    Forum.instance_variable_set :@cached, nil
    Forum.instance_variable_set :@with_aggregated, nil
  end

  describe '#to_a' do
    it { expect(view.to_a).to have_at_least(5).items }
  end

  describe '.defaults' do
    it { expect(Forums::List.defaults).to have_at_least(4).items }
    # it { expect(Forums::List.defaults).to include offtopic_forum.id }
  end
end
