class Capybara::Node::Element
  def submit
    raise "Can only submit form, not #{tag_name}" unless tag_name =~ /form/i
    unless session.driver.kind_of? Capybara::RackTest::Driver
      return session.evaluate_script "$('##{self['id']}').submit()"
    end

    Capybara::RackTest::Form.new(driver, self.native).submit(self)
  end
end

# открыть в браузере: save_and_open_page
# выполнить скрипт: ap Nokogiri::HTML page.evaluate_script "$(document.body).html()"
# получить body: ap Nokogiri::HTML page.body
# другие примеры: https://gist.github.com/zhengjia/428105
module FeatureHelpers
  def sign_in user
    visit new_user_session_path

    fill_in 'user[nickname]', with: user.nickname
    fill_in 'user[password]', with: user.password

    find('form').submit
  end

  def sign_up user, sign_up_url=new_user_registration_path
    visit sign_up_url

    fill_in 'user[nickname]', with: user.nickname
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password

    find('form').submit
  end

  def confirmation user
    fill_in 'confirmation_token', with: user.confirmation_token
    find('form').submit
  end

  def confirmation_new user
    visit new_user_confirmation_path
    fill_in 'user_email', with: user.email

    find('form').submit
  end

  def forgot_password user
    visit new_user_password_path
    fill_in 'user_email', with: user.email

    find('form').submit
  end

  def restore_password user, public_token
    visit edit_user_password_path(reset_password_token: public_token)
    fill_in 'user[password]', with: '123456'
    fill_in 'user[password_confirmation]', with: '123456'
    find('form').submit
  end
end
