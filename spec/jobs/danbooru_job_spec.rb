
require 'spec_helper'

describe DanbooruJob do
  let(:filepath) { '/tmp/DanbooruJob' }

  before(:each) do
    File.open(filepath, 'w') {|h| h.write 'test' }
    AWS::S3::S3Object.stub(:store)
    $redis.stub(:set)
  end

  it 'should store file in s3' do
    AWS::S3::S3Object.should_receive(:store).once
    DanbooruJob.new('md5', 'url', filepath).perform
  end

  it 'should hit redis' do
    $redis.should_receive(:set).once.with('md5', true)
    DanbooruJob.new('md5', 'url', filepath).perform
  end

  it 'should delete tmp file' do
    DanbooruJob.new('md5', 'url', filepath).perform
    File.exists?(filepath).should be_false
  end

  it 'should log error when tmp file not exists' do
    Rails.logger.stub(:error)
    Rails.logger.should_receive(:error).once

    File.delete(filepath)

    DanbooruJob.new('md5', 'url', filepath).perform
  end
end
