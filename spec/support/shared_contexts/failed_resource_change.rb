shared_examples_for :failed_resource_change do |is_ignore_model_check|
  it do
    unless is_ignore_model_check
      expect(resource).to_not be_valid
      expect(resource.changes).to_not be_empty
    end

    expect(json).to include :errors
    expect(json[:errors]).to be_kind_of Array

    expect(response.content_type).to eq 'application/json; charset=utf-8'
    expect(response).to have_http_status 422
  end
end
