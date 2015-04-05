module User::TokenAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_save :ensure_api_access_token

    def ensure_api_access_token
      if api_access_token.blank?
        self.api_access_token = generate_api_access_token
      end
    end

  private
    def generate_api_access_token
      loop do
        token = Devise.friendly_token
        break token unless User.find_by(api_access_token: token)
      end
    end
  end
end
