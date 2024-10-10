# to make docs recording work again revert this commit in apipie
# https://github.com/Apipie/apipie-rails/commit/e3eab0a33eaff8e8311eee3f478feabde7d906ae
# https://github.com/Apipie/apipie-rails/issues/622
Apipie.configure do |config|
  config.app_name                = 'Shikimori API'
  config.api_base_url            = '/api'
  config.doc_base_url            = '/api/doc'
  config.show_all_examples       = true
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version         = '2.0'
  config.api_routes              = Rails.application.routes
  config.markup                  = Apipie::Markup::Markdown.new
  config.translate               = false
  config.generated_doc_disclaimer =
    '# AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING'

  version_placeholder = '%%VERSION_PLACEHOLDER%%'
  documentation_placeholder = '%%DOCUMENTATION_PLACEHOLDER%%'
  pagination_placeholder = '%%PAGINATION_PLACEHOLDER%%'

  app_info = <<~MARKDOWN
    ## Welcome to Shikimori API #{version_placeholder}
    The API has three versions:
      [**graphql**](/api/doc/graphql),
      outdated [**v2**](/api/doc/2.0.html) and
      outdated [**v1**](/api/doc/1.0.html).
      Prefer using `graphql` over `v2`/`v1` when it is possible.

    **Please do not parse the main site**. Fetch all necessary data via API.

    **NOTE:** New anime/manga/character/person posters available only in `graphql` API.

    API works with `HTTPS` protocol only.
    <br><br>

    ### Documentation for GraphQL
    [Click here](/api/doc/graphql).
    <br><br>

    #{documentation_placeholder}

    ### Authentication
    OAuth2 is used for authentication. [OAuth2 guide](/oauth).<br>
    All other auth methods are deprecated and will be removed after 2018-07-01.
    <br><br>

    ### Restrictions
    API access is limited by `5rps` and `90rpm`
    <br><br>

    ### Requirements
    Add your Oauth2 Application name to `User-Agent` requests header.

    Don't mimic a browser.

    Your IP address may be banned if you use API without properly set `User-Agent` header.
    <br><br>

    #{pagination_placeholder}### Third party implementations
    [Python API implementation](https://github.com/OlegWock/PyShiki) by OlegWock.

    [Node.js API implementation](https://github.com/Capster/node-shikimori) by Capster.

    [C# API implementation](https://github.com/JustRoxy/ShikimoriSharp) by JustRoxy.

    [Ruby API implementation](https://github.com/iwdt/shikikit#shikimori-api) by iwdt.
    <br><br>

    ### Feedback
    [@morr](/morr), [email](mailto:#{Shikimori::EMAIL})
    <br><br>
  MARKDOWN

  v1_documentation = <<~MARKDOWN
    ### Documentation for V1
    On this page below.
    <br><br>

    ### Documentation for V2
    [Click here](/api/doc/2.0.html).
    <br><br>
  MARKDOWN

  v2_documentation = <<~MARKDOWN
    ### Documentation for V1
    [Click here](/api/doc/1.0.html).
    <br><br>

    ### Documentation for V2
    On this page below.
    <br><br>
  MARKDOWN

  v1_pagination = <<~MARKDOWN
    ### Pagination in API
    When you request `N` elements from paginated API, in most cases you will get `N+1` results if API has next page.
    <br><br>

  MARKDOWN

  v2_pagination = <<~MARKDOWN
  MARKDOWN

  config.app_info['1.0'] = app_info
    .gsub(version_placeholder, 'v1')
    .gsub(documentation_placeholder, v1_documentation)
    .gsub(pagination_placeholder, v1_pagination)

  config.app_info['2.0'] = app_info
    .gsub(version_placeholder, 'v2')
    .gsub(documentation_placeholder, v2_documentation)
    .gsub(pagination_placeholder, v2_pagination)
end

class DateTimeValidator < Apipie::Validator::BaseValidator
  def initialize param_description, argument
    super param_description
    @type = argument
  end

  def validate(value)
    return false if value.nil?

    value.to_s.match? ActiveSupport::JSON::DATETIME_REGEX
  end

  def self.build param_description, argument, _options, _block
    if argument == DateTime
      new(param_description, argument)
    end
  end

  def description
    'Must be a date in `iso8601` `YYYY-MM-DDThh:mm:ss±hh` format'
  end
end
