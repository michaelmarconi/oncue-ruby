require 'spec_helper'

require 'oncue/configuration'
require 'oncue/exceptions'

describe OnCue::Configuration do

  let(:configuration) { OnCue::Configuration.new }

  describe '.new' do

    context 'without any arguments' do
      it do
        configuration.host.should eq 'localhost'
        configuration.port.should eq 9000
        configuration.base.should eq 'api'
      end
    end

    context 'with arguments' do

      let(:host) { 'com.example' }
      let(:port) { 1234 }
      let(:base) { 'oncue' }

      let(:configuration) { OnCue::Configuration.new host, port, base}

      subject { configuration }

      it do
        configuration.host.should eq 'com.example'
        configuration.port.should eq 1234
        configuration.base.should eq 'oncue'
      end

      context 'host is nil' do
        let(:host) { nil }

        it do
          expect { OnCue::Configuration.new host, port, base }.to raise_error OnCue::InvalidConfigurationError
        end

      end

    end

  end

  context 'redefining host to nil' do
    it do
      expect{ configuration.host = nil }.to raise_error OnCue::InvalidConfigurationError
    end
  end

  describe '#jobs_url' do

    subject { configuration.jobs_url }

    context 'with default configuration' do
      it { should eq 'http://localhost:9000/api/jobs' }
    end

    context 'with custom configuration' do

      before do
        configuration.host = 'example.com'
        configuration.port = 1234
        configuration.base = 'oncue'
      end

      it { should eq 'http://example.com:1234/oncue/jobs' }

    end

    context 'when base has been redefined' do

      context 'to nil' do
        before { configuration.base = nil }
        it { should eq 'http://localhost:9000/jobs' }
      end

      context 'to another string' do
        before { configuration.base = 'oncue' }
        it { should eq 'http://localhost:9000/oncue/jobs' }
      end

    end

    context 'when host has been redefined' do

      context 'to another string' do
        before { configuration.host = 'example.com' }
        it { should eq 'http://example.com:9000/api/jobs' }
      end

    end

    context 'when port has been redefined' do

      context 'to nil' do
        before { configuration.port = nil }
        it { should eq 'http://localhost/api/jobs' }
      end

      context 'to another port' do

        context 'as a string' do
          before { configuration.port = '1234' }
          it { should eq 'http://localhost:1234/api/jobs' }
        end

        context 'as an integer' do
          before { configuration.port = 1234 }
          it { should eq 'http://localhost:1234/api/jobs' }
        end

      end

    end

  end

  describe '#==' do
    let(:config_1) { OnCue::Configuration.new }
    let(:config_2) { OnCue::Configuration.new }

    subject { config_1 == config_2 }

    context 'comparing an instance to itself' do
      subject { config_1 == config_2 }
      it { should eq true}
    end

    context 'comparing different instances' do

      context 'with default attributes' do
        it { should eq true}
      end

      context 'with non-default but identical attributes' do

        before do
          config_1.base = 'something'
          config_1.host = 'com.example'
          config_1.port = 1234

          config_2.base = 'something'
          config_2.host = 'com.example'
          config_2.port = 1234
        end

        it { should eq true }

      end

      context 'with different bases' do

        before do
          config_1.base = 'something'
          config_2.base = 'other'
        end

        it { should eq false }

      end

      context 'with different hosts' do

        before do
          config_1.host = 'com.example'
          config_2.host = 'org.other'
        end

        it { should eq false}

      end

      context 'with different ports' do

        before do
          config_1.port = 1234
          config_2.port = 4321
        end

        it { should eq false }

      end

    end

  end

end