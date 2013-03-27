require 'addressable/template'

module OnCue
  class Configuration

    URI_TEMPLATE = Addressable::Template.new('http://{host}:{port}{/base}{/resource}')
    private_constant :URI_TEMPLATE

    attr_accessor :host, :port, :base

    def initialize(host = 'localhost', port = 9000, base = 'api')
      self.host= host
      @port = port
      @base = base
    end

    def host=(host)
      raise OnCue::InvalidConfigurationError, 'Host cannot be nil.' if host.nil?
      @host = host
    end

    def jobs_url
      URI_TEMPLATE.expand(host: @host, port: @port, base: @base, resource: 'jobs').to_s
    end

    def ==(other)
      other.equal?(self) || (
        other.instance_of?(self.class) &&
        other.base == @base && other.host == @host && other.port == @port
      )
    end

  end
end