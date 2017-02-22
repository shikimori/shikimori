Apipie.configure do |config|
  config.app_name                = 'Shikimori API'
  config.api_base_url            = '/api'
  config.doc_base_url            = '/api/doc'
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version         = '2.0'
  config.api_routes              = Rails.application.routes
  config.markup                  = Apipie::Markup::Markdown.new
  config.generated_doc_disclaimer =
    '# AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING'

  version_placeholder = '%%VERSION_PLACEHOLDER%%'
  documentation_placeholder = '%%DOCUMENTATION_PLACEHOLDER%%'
  app_info = <<-MARKDOWN
    ## Welcome to Shikimori API #{version_placeholder}
    This API has two versions:
      [**v2**](https://shikimori.org/api/doc/2.0.html) and
      [**v1**](https://shikimori.org/api/doc/1.0.html).
      `v2` consists of newly updated methods.
      Prefer using `v2` over `v1` when it is possible.
    <br><br>

    #{documentation_placeholder}

    ### Authentication
    Retrieve `<user_api_access_token>` via
      [Access tokens API](https://shikimori.org/api/doc/1.0/access_tokens/create)
      and add `X-User-Nickname`, `X-User-Api-Access-Token` headers to every api request.

    `X-User-Nickname=<user_nickname>` `X-User-Api-Access-Token=<user_api_access_token>`
    <br><br>

    ### Restrictions
    Never parse the main site. Use `v2` and `v1` API.

    Don't mimic a browser. Put your application name or website url into `User-Agent` request header.

    API access limited by `5rps` `90rpm`

    `HTTPS` protocol only.
    <br><br>

    ### Third party
    [Python API implementation](https://github.com/OlegWock/PyShiki) by OlegWock.
    [Node.js API implementation](https://github.com/Capster/node-shikimori) by Capster.
    <br><br>

    ### Feedback
    [@morr](http://shikimori.org/morr), [email](mailto:takandar@gmail.com)
    <br><br>
  MARKDOWN

  v1_placeholder = <<-MARKDOWN

    ### Documentation for v1
    On this page below.
    <br><br>

    ### Documentation for v2
    [Click here](https://shikimori.org/api/doc/2.0.html).
    <br><br>
  MARKDOWN

  v2_placeholder = <<-MARKDOWN

    ### Documentation for v1
    [Click here](https://shikimori.org/api/doc/1.0.html).
    <br><br>

    ### Documentation for v2
    On this page below.
    <br><br>
  MARKDOWN

  config.app_info['1.0'] = app_info
    .gsub(version_placeholder, 'v1')
    .gsub(documentation_placeholder, v1_placeholder)

  config.app_info['2.0'] = app_info
    .gsub(version_placeholder, 'v2')
    .gsub(documentation_placeholder, v2_placeholder)
end
