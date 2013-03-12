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
    context 'with parameter keys that are' do

      let(:stored_params) do
        job = OnCue.enqueue_job('oncue.workers.TestWorker', {key => 'value'})
        job_key = OnCue::JOB_KEY % { :job_id => 1 }
        JSON.parse(redis.hget(job_key, OnCue::JOB_PARAMS))
      end

      context 'nil' do
        let(:key) {nil}

        it 'throws an error' do
          expect {stored_params}.to raise_error
        end
      end

      context 'strings' do
        let(:key) {'a string'}

        it 'converts them to strings' do
          stored_params.should == {'a string' => 'value'}
        end
      end

      context 'integers' do
        let(:key) {10}
        it 'converts them to strings' do
          stored_params.should == {'10' => 'value'}
        end
      end
      context 'decimals' do
        let(:key) {10.23}
        it 'converts them to strings' do
          stored_params.should == {'10.23' => 'value'}
        end
      end

      context 'the boolean true' do
        let(:key) {true}
        it 'converts them to strings' do
          stored_params.should == {'true' => 'value'}
        end
      end

      context 'the boolean false' do
        let(:key) {false}
        it 'converts them to strings' do
          stored_params.should == {'false' => 'value'}
        end
      end

      context 'symbols' do
        let(:key) {:a_symbol}
        it 'converts them to strings' do
          stored_params.should == {'a_symbol' => 'value'}
        end
      end

      context 'arrays' do
        let(:key) {[1,true,'string']}
        it 'converts them to strings' do
          stored_params.should == {'[1, true, "string"]' => 'value'}
        end
      end

      context 'maps' do
        let(:key) {{1 => false}}
        it 'converts them to strings' do
          stored_params.should == {'{1=>false}' => 'value'}
        end
      end

      context 'arbitrary objects' do
        let(:key) {Object.new}
        it 'converts them to strings using the to_s method' do
          stored_params.keys[0].should =~ /Object.*/
        end
      end
    end

    context 'with parameter values that are' do

      let(:stored_params) do
        job = OnCue.enqueue_job('oncue.workers.TestWorker', {'key' => value})
        job_key = OnCue::JOB_KEY % { :job_id => 1 }
        JSON.parse(redis.hget(job_key, OnCue::JOB_PARAMS))
      end


      context 'nil' do
        let(:value) {nil}

        it 'leaves them as nil' do
          stored_params.should == {'key' => nil}
        end
      end

      context 'strings' do
        let(:value) {'a string'}

        it 'converts them to strings' do
          stored_params.should == {'key' => 'a string'}
        end
      end

      context 'integers' do
        let(:value) {10}
        it 'converts them to strings' do
          stored_params.should == {'key' => '10'}
        end
      end
      context 'decimals' do
        let(:value) {10.23}
        it 'converts them to strings' do
          stored_params.should == {'key' => '10.23'}
        end
      end

      context 'the boolean true' do
        let(:value) {true}
        it 'converts them to strings' do
          stored_params.should == {'key' => 'true'}
        end
      end

      context 'the boolean false' do
        let(:value) {false}
        it 'converts them to strings' do
          stored_params.should == {'key' => 'false'}
        end
      end

      context 'symbols' do
        let(:value) {:a_symbol}
        it 'converts them to strings' do
          stored_params.should == {'key' => 'a_symbol'}
        end
      end

      context 'arrays' do
        let(:value) {[1,true,'string']}
        it 'converts them to strings' do
          stored_params.should == {'key' => '[1, true, "string"]'}
        end
      end

      context 'maps' do
        let(:value) {{1 => false}}
        it 'converts them to strings' do
          stored_params.should == {'key' => '{1=>false}'}
        end
      end

      context 'arbitrary objects' do
        let(:value) {Object.new}
        it 'converts them to strings using the to_s method' do
          stored_params.should == {'key' => value.to_s}
        end
      end
    end
  end
end
