# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/fonts"

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
# Rails.application.config.assets.precompile += [
  # Proc.new { |path| !%w(.js .css).include?(File.extname(path)) },
  # /.*.(css|js)$/
# ]
# vendor/jquery.cookie - for age_restricted.html.slim
Rails.application.config.assets.precompile += %w(
  page503.css
  page404.css
  age_restricted.css
)
