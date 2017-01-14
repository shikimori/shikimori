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
  config.app_info                = <<-MARKDOWN
    ## Welcome to Shikimori API
    This API has two versions:
      [**v2**](https://shikimori.org/api/doc/2.0.html) and
      [**v1**](https://shikimori.org/api/doc/1.0.html).
      `v2` consists of newly updated methods.
      Prefer using `v2` over `v1` when it is possible.
    <br><br>

    ### Authentication
    Retrieve `<user_api_access_token>` via
      [Access tokens API](https://shikimori.org/api/doc/1.0/access_tokens/create)
      and add `X-User-Nickname` & `X-User-Api-Access-Token` headers to every your api request.

    `X-User-Nickname=<user_nickname>` `X-User-Api-Access-Token=<user_api_access_token>`
    <br><br>

    ### Restrictions
    Never parse the main site. Use `v2` and `v1` API.

    Don't mimic a browser. Put your application name or website url into `User-Agent` request header.

    API access limits: `5rps` `90rpm`.

    `HTTPS` protocol only.
    <br><br>

    [Python API implementation](https://github.com/OlegWock/PyShiki) by OlegWock.
    <br><br>
    Message me on [my shikimori profile](http://shikimori.org/morr) or [by email](mailto:takandar@gmail.com) if you have any questions or you need more data in api.
    <br><br>
  MARKDOWN
end
