# onCue

[![Build Status](https://travis-ci.org/michaelmarconi/oncue-ruby.png)](https://travis-ci.org/michaelmarconi/oncue-ruby)

## Installation

    gem install oncue

## Configuration

### Default

The gem is pre-configured with the values `oncue-service` uses out-of-the-box. It will use `http://localhost:9000/api`
as the base URL for all requests by default.

### Changing the Configuration

You can configure the `host`, `port` and URI `base` used to connect to the API.
    
    OnCue.configure do |config|
        config.host = 'example.com'
        config.port = 1234
        config.base = 'oncue'
    end
    
    # Base URL: http://example.com:1234/oncue
    
Host and port are optional, they will be omitted from the base URL:
    
    OnCue.configure do |config|
      config.host = 'example.com'
      config.port = nil
      config.base = nil
    end
    
    # Base URL: http://example.com
    
## Usage

    require 'oncue'
    
    OnCue.enqueue_job('com.example.Worker', { 'my' => 'lovely', 'params' => 'go here' })
    
## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
    

