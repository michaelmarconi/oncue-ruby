require 'spec_helper'
require 'redis'

describe OnCue do

  describe 'enqueue_job' do

    # Grab a connection to Redis and flush the database
    before(:each) do
      @redis = Redis.new(:host => "localhost", :port => 6379)
      @redis.flushdb()
    end

    it 'should enqueue a new job in Redis without params' do

      # Use the API to enqueue the job
      job = OnCue.enqueue_job('oncue.workers.TestWorker')

      # Now fish the job out of Redis
      job_key = OnCue::JOB_KEY % { :job_id => 1 }
      @redis.hget(job_key, OnCue::JOB_ENQUEUED_AT).should == job.enqueued_at.to_s
      @redis.hget(job_key, OnCue::JOB_WORKER_TYPE).should == job.worker_type

      # And check it is on the new jobs queue
      @redis.rpop(OnCue::NEW_JOBS_QUEUE).should == "1"
    end

    context 'with params that are not key value pairs' do

      it 'should reject the job' do
        expect { OnCue.enqueue_job('oncue.workers.TestWorker', ['an array']) }.to raise_error
      end

    end

    it 'should enqueue a new job in Redis without params' do

      # Use the API to enqueue the job
      job = OnCue.enqueue_job('oncue.workers.TestWorker')

      # Now fish the job out of Redis
      job_key = OnCue::JOB_KEY % { :job_id => 1 }
      @redis.hget(job_key, OnCue::JOB_ENQUEUED_AT).should == job.enqueued_at.to_s
      @redis.hget(job_key, OnCue::JOB_WORKER_TYPE).should == job.worker_type

      # And check it is on the new jobs queue
      @redis.rpop(OnCue::NEW_JOBS_QUEUE).should == "1"
    end

  end
end