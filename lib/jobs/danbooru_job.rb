# загрузка картинки, лежащей в локальной файловой системе, на s3
class DanbooruJob < Struct.new(:md5, :url, :filepath)
  def perform
    unless File.exists?(filepath)
      Rails.logger.error "image #{filepath} is not found in local file system"
      return
    end
    image = open(filepath, 'rb')
    AWS::S3::S3Object.store(md5,
                            image.read,
                            S3_CREDENTIALS['bucket'],
                            :content_type => image.content_type,
                            :access => :public_read,
                            'x-amz-storage-class' => 'REDUCED_REDUNDANCY')
    File.delete(filepath)
    $redis.set(md5, true)
  end
end
