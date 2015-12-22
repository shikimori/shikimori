describe Forums::List do
  include_context :view_object_warden_stub

  let(:user) { seed :user }
  let(:view) { Forums::List.new }

  before do
    Section.instance_variable_set :@static, nil
    Section.instance_variable_set :@with_aggregated, nil
    Section.instance_variable_set :@real, nil
  end

  describe '#to_a' do
    it { expect(view.to_a).to have(3).items }
  end
end
