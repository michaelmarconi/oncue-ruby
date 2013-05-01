require 'spec_helper'

require 'date'
require 'oncue/job'

describe OnCue::Job do

  describe '.json_create' do

    let(:id) { 1 }
    let(:enqueued_at) { '2013-03-26T12:34:56' }
    let(:json) { { 'id' => id, 'enqueued_at' => enqueued_at } }

    subject(:created_job) { OnCue::Job.json_create(json) }

    context 'with valid JSON' do

      it do
        created_job.id.should eq 1
        created_job.enqueued_at.should eq DateTime.new(2013, 03, 26, 12, 34, 56)
      end

      context 'where enqueued_at is not IS8061 formatted' do

        let(:enqueued_at) { 'Thursday 28th Match 2013' }

        it do
          expect { created_job }.to raise_error ArgumentError
        end

      end

    end

  end

  describe '#==' do

    let(:job_1) { OnCue::Job.new(1, '2013-03-26T12:34:56') }
    let(:job_2) { OnCue::Job.new(2, '1924-11-30T01:23:45') }

    subject { job_1 == job_2 }

    context 'comparing and instance to itself' do
      subject { job_1 == job_1 }
      it { should eq true}
    end

    context 'comparing different instances' do

      context 'with different attributes' do
        it { should eq false}
      end

      context 'with the same attributes' do

        let(:job_1) { OnCue::Job.new(1, '2013-03-26T12:34:56') }
        let(:job_2) { OnCue::Job.new(1, '2013-03-26T12:34:56') }

        it { should eq true}

      end

    end

  end

end
