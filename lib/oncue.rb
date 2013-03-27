require 'json'
require 'net/http'
require 'rest_client'

require 'oncue/configuration'
require 'oncue/exceptions'
require 'oncue/job'
require 'oncue/parameters'

module OnCue

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
    @configuration
  end

  def self.enqueue_job(worker_type, params = {})
    raise ArgumentError.new('Worker type must be a string') unless worker_type.kind_of? String
    raise ArgumentError.new('Job params must be nil or a Hash') unless params.nil? or params.kind_of? Hash

    params = OnCue::Parameters.convert_param_values_to_strings(params)

    request_json = JSON.dump(workerType: worker_type.to_s, params: params)

    begin
      response = RestClient.post(configuration.jobs_url, request_json, content_type: :json, accept: :json)
      case response.code
        when 200
            job_json = JSON.parse(response.body)
            OnCue::Job.json_create(job_json)
        else
          raise OnCue::JobNotQueuedError
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      raise OnCue::JobNotQueuedError
    rescue JSON::ParserError => e
      raise OnCue::UnexpectedServerResponse
    end
  end

end
