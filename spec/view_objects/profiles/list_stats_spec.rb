describe Profiles::ListStats do
  include_context :view_object_warden_stub

  let(:user) { seed :user }
  let(:view) do
    Profiles::ListStats.new(
      name: 'planned',
      type: 'Anime',
      grouped_id: '1,2',
      size: 10
    )
  end

  it { expect(view.id).to eq 0 }
  it { expect(view.localized_name).to eq 'Запланировано' }
  it { expect(view.url).to include "/#{user.to_param}/list/#{view.type.downcase}/mylist/#{view.grouped_id}" }
  it { expect(view.any?).to eq true }
end
