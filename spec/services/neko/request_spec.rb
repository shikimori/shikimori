describe Neko::Request, :vcr do
  subject { Neko::Request.call params }
  let(:params) { { user_id: 1, action: Types::Neko::Action[:noop] } }

  it do
    is_expected.to eq(
      updated: [],
      removed: [
        {
          user_id: 1,
          progress: 0,
          neko_id: 'test',
          level: 1
        }
      ],
      added: [
        {
          user_id: 1,
          progress: 100,
          neko_id: 1,
          level: 0
        },
        {
          user_id: 1,
          progress: 100,
          neko_id: 1,
          level: 1
        },
        {
          user_id: 1,
          progress: 100,
          neko_id: 1,
          level: 2
        },
        {
          user_id: 1,
          progress: 100,
          neko_id: 1,
          level: 3
        },
        {
          user_id: 1,
          progress: 70,
          neko_id: 1,
          level: 4
        }
      ]
    )
  end
end
