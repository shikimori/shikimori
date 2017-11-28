module User::TokenAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_save :reset_api_access_token, if: -> { api_access_token.blank? }
    before_save :reset_api_access_token,
      if: -> { encrypted_password_changed? }

    def reset_api_access_token
      self.api_access_token = generate_api_access_token
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
