require 'redis'
require 'time'
require 'job'

module OnCue
  extend self

  JOB_COUNT_KEY = "oncue:job_count"
  JOB_KEY = "oncue:jobs:%{job_id}"
  JOB_WORKER_TYPE = "job_worker_type"
  JOB_ENQUEUED_AT = "job_enqueued_at"
  NEW_JOBS_QUEUE = "oncue:jobs:new"

  def enqueue_job(worker_type)

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
      redis.lpush(NEW_JOBS_QUEUE, job_id)
    end
    return Job.new(job_id, worker_type, enqueued_at)
  end
end
