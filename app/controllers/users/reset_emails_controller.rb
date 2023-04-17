class Users::ResetEmailsController < ProfilesController
  before_action :check_access!

  def new
    @email_text = <<-TEXT.gsub(/^ +/, '')
      Привет!
      К Шикимори аккаунту #{@resource.url} теперь привязана твоя почта %<email>s.
      Сбросить пароль теперь можно по ссылке %<recovery_url>s.
    TEXT
  end

private

  def set_breadcrumbs
    super
    og page_title: 'Изменение почты'
    breadcrumb 'Модерация', moderation_profile_url(@resource)
  end

  def check_access!
    authorize! :reset_email, @resource
  end
end
