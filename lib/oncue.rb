require 'redis'
require 'time'
require 'job'
require 'oncue_exception'
require 'json'

module OnCue
  extend self

  # job counter key
  JOB_COUNT_KEY = "oncue:job_count"

  # job dictionary key template
  JOB_KEY = "oncue:jobs:%{job_id}"

  # job dictionary key
  JOB_WORKER_TYPE = "job_worker_type"

  # job enqueue time key
  JOB_ENQUEUED_AT = "job_enqueued_at"

  # job parameters key
  JOB_PARAMS = "job_params"

  # new jobs queue name
  NEW_JOBS_QUEUE = "oncue:jobs:new"

  def enqueue_job(worker_type, params={})
    raise 'params must be a set of key-value pairs' unless params.kind_of? Hash

    params.merge!(params) do |key, value|
      raise OnCueException, 'nil is not a valid key' if key.nil?
      value.nil? ? nil : value.to_s
    end

    # Connect to redis
    redis = Redis.new(:host => "localhost", :port => 6379)
    
    # Get the latest job ID
    job_id = redis.incr(JOB_COUNT_KEY);

    # Save the job and push it onto the
    # new jobs queue in a single transaction
    enqueued_at = Time.now.utc.iso8601
    redis.multi do
      job_key = JOB_KEY % { :job_id => job_id }
      redis.hset(job_key, JOB_ENQUEUED_AT, enqueued_at)
      redis.hset(job_key, JOB_WORKER_TYPE, worker_type)
      redis.hset(job_key, JOB_PARAMS, params.to_json)
      redis.lpush(NEW_JOBS_QUEUE, job_id)
    end
    return Job.new(job_id, worker_type, enqueued_at)
  end
end
