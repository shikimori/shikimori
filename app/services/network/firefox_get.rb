require 'selenium-webdriver'

class Network::FirefoxGet
  method_object :url

  def call
    # Set up the Selenium WebDriver
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('--headless') # Run in headless mode, no browser UI

    driver = Selenium::WebDriver.for(:firefox, options:)

    # Fetch the page
    driver.navigate.to url

    # Give the page some time to load and execute JS (adjust the sleep time if needed)
    sleep 2

    # Get the page HTML after JS execution
    html = driver.page_source

    # Close the browser
    driver.quit

    html
  end
end
