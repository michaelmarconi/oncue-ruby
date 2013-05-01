require 'spec_helper'

require 'json'
require 'net/http'
require 'oncue'
require 'oncue/configuration'
require 'oncue/job'

describe OnCue do

  after(:each) do
    OnCue.configure do  |config|
      config.host = 'localhost'
      config.port = 9000
      config.base = 'api'
    end
  end

  describe '.configuration' do

    subject { OnCue.configuration }

    context 'called for the first time' do
      it { should eq OnCue::Configuration.new }
    end

    context 'called after the configuration has changed' do

      before do
        OnCue.configuration.port = 1234
      end

      it { should_not eq OnCue::Configuration.new }

      it do
        should eq OnCue::Configuration.new('localhost', 1234, 'api')
      end

    end

  end

  describe '.configure' do
    context 'allows configuration as a block' do

      subject do
        OnCue.configure do |config|
          config.host = 'com.example'
          config.port = 5678
          config.base = 'oncue'
        end
        OnCue.configuration
      end

      it do
        should eq OnCue::Configuration.new('com.example', 5678, 'oncue')
      end

    end
  end

  describe '.enqueue_job' do

    let(:worker_type) { 'com.example.Worker' }
    let(:params) { {} }

    subject(:enqueue_job) { OnCue.enqueue_job(worker_type, params) }

    context 'with invalid argument' do

      context 'worker_type is not a string' do

        let(:worker_type) { nil }

        it { expect { enqueue_job }.to raise_error ArgumentError }

      end

      context 'params is not nil, or a hash' do

        let(:params) { 1 }

        it { expect { enqueue_job }.to raise_error ArgumentError }

      end

    end

    context 'with valid arguments' do

      let(:jobs_url) { 'http://test/' }

      let(:params) { {'a' => 'b'}}
      let(:request_body) {  "{\"worker_type\":\"#{worker_type}\",\"params\":#{JSON.dump(params)}}" }

      let(:status) { 200 }
      let(:response_body) { '{"id":1,"enqueued_at":"2013-03-26T12:34:56"}' }

      before do
        OnCue.configuration.should_receive(:jobs_url).and_return(jobs_url)
        stub_request(:post, jobs_url).
          with(
            body: request_body,
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip, deflate',
              'Content-Length'=>request_body.length,
              'Content-Type'=>'application/json',
              'User-Agent'=>'Ruby'
            }
          ).to_return(status: status, body: response_body, :headers => {})
      end

      context 'that succeeds' do

        context 'with a valid JSON response from the server' do

          it { should eq OnCue::Job.new(1, '2013-03-26T12:34:56') }

        end

        context 'with an invalid JSON response' do

          context '"nil" from the server' do

            let(:response_body) { nil }

            it do
              expect { enqueue_job }.to raise_error OnCue::UnexpectedServerResponse
            end
          end

          context 'with a non ISO8601-formatted date' do

            let(:response_body) { '{"id":1,"enqueued_at":"Thursday 28th March 2013"}' }

            it do
              expect { enqueue_job }.to raise_error OnCue::UnexpectedServerResponse
            end

          end

        end

      end

      context 'that fails' do

        context 'due to an internal server error' do

          let(:status) { 500 }

          it do
            expect { enqueue_job }.to raise_error OnCue::JobNotQueuedError
          end
        end

        context 'due to being unable to connect to the server' do

          before do
            stub_request(:post, jobs_url).to_raise(Errno::ECONNREFUSED)
          end

          it do
            expect { enqueue_job }.to raise_error OnCue::JobNotQueuedError
          end

        end

      end

    end

  end

end
