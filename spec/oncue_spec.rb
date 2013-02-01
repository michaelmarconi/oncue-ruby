require 'spec_helper'
require 'redis'

describe OnCue do

  describe 'enqueue_job' do

    let(:redis) {Redis.new(:host => "localhost", :port => 6379)}

    # Grab a connection to Redis and flush the database
    before(:each) do
      redis.flushdb()
    end

    it 'should enqueue a new job in Redis without params' do

      # Use the API to enqueue the job
      job = OnCue.enqueue_job('oncue.workers.TestWorker')

      # Now fish the job out of Redis
      job_key = OnCue::JOB_KEY % { :job_id => 1 }
      redis.hget(job_key, OnCue::JOB_ENQUEUED_AT).should == job.enqueued_at.to_s
      redis.hget(job_key, OnCue::JOB_WORKER_TYPE).should == job.worker_type

      # And check it is on the new jobs queue
      redis.rpop(OnCue::NEW_JOBS_QUEUE).should == "1"
    end

    context 'with params' do

      context 'that are not key value pairs' do
        it 'should reject the job' do
          expect { OnCue.enqueue_job('oncue.workers.TestWorker', ['an array']) }.to raise_error
        end
      end

      context 'that are key value pairs ' do
        it 'should enqueue a new job in Redis with params' do

          params = {'size' => 10, 'day' => 'Tuesday'}
          # Use the API to enqueue the job
          job = OnCue.enqueue_job('oncue.workers.TestWorker', params)

          # Now fish the job out of Redis
          job_key = OnCue::JOB_KEY % { :job_id => 1 }
          redis.hget(job_key, OnCue::JOB_ENQUEUED_AT).should == job.enqueued_at.to_s
          redis.hget(job_key, OnCue::JOB_WORKER_TYPE).should == job.worker_type
          JSON.parse(redis.hget(job_key, OnCue::JOB_PARAMS)).should == params

          # And check it is on the new jobs queue
          redis.rpop(OnCue::NEW_JOBS_QUEUE).should == "1"
        end
      end
    end


  end
end