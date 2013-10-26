
# Load AWS::S3 configuration values
#S3_CREDENTIALS = YAML.load_file(File.join(Rails.root, 'config/s3_credentials.yml'))[Rails.env]
S3_CREDENTIALS_PATH = "#{ENV['HOME']}/shikimori.org/s3.yml"
S3_CREDENTIALS = YAML.load_file(S3_CREDENTIALS_PATH)[Rails.env]

# Set the AWS::S3 configuration
AWS::S3::Base.establish_connection! S3_CREDENTIALS['connection']
AWS::S3::DEFAULT_HOST.replace "s3-eu-west-1.amazonaws.com"
