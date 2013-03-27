require 'spec_helper'

require 'oncue/parameters'

describe OnCue::Parameters do

  describe '.convert_param_values_to_strings' do

    let(:params) { {} }

    subject { OnCue::Parameters.convert_param_values_to_strings(params) }

    context 'params is' do

      context 'nil' do
        let(:params) { nil }

        it { should eq nil }

      end

      context 'a hash' do

        context 'that is empty' do
          let(:params) { {} }

          it { should == {} }

        end

        context 'with non-string keys' do

          context 'and all values are strings' do

            let(:params) { { 1 => 'a', 2 => 'b' } }

            it { should == params }

          end

          context 'and some values are not strings' do

            let(:params) { { 1 => 1, 2 => 2 } }

            it { should == { 1 => '1', 2 => '2' }}

          end

        end

      end

      context 'not nil or a hash' do

        let(:params) { 1 }

        it do
          expect { should }.to raise_error ArgumentError
        end

      end

    end

  end

end