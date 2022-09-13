shared_examples :has_access do
  before { subject }

  it 'has_access' do
    expect(response).to have_http_status :success
  end
end

shared_examples :has_no_access_got_404 do
  it 'has_no_access_got_404' do
    expect { subject }.to raise_error ActiveRecord::RecordNotFound
  end
end
