class Api::V1::ApiController < ApplicationController
  responders :json # для рендеринга контента на patch и put запросы

  resource_description do
    api_version '1'
  end
end
