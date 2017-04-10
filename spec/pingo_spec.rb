require 'spec_helper'

describe Pingo do
  it 'has a version number' do
    expect(Pingo::VERSION).not_to be_nil
  end

  describe "#sound!" do
    let(:client) { Pingo::Client.new(model_name) }

    context 'valid id & pass' do
      before { set_valid_env }

      context 'valid model_name' do
        let(:model_name) { "5s" }

        it 'should return device_id' do
          VCR.use_cassette 'valid_interaction' do
            expect(client.sound!).not_to be_nil
          end
        end
      end

      context 'invalid model_name' do
        let(:model_name) { "100s" }

        it 'should not return device_id' do
          VCR.use_cassette 'valid_interaction' do
            expect { client.sound! }.to raise_error(RuntimeError, "Not found your device(iPhone#{model_name})")
          end
        end
      end
    end

    context 'invalid id & pass' do
      before { set_invalid_env }

      context 'valid model_name' do
        let(:model_name) { "5s" }

        it 'should return device_id' do
          VCR.use_cassette 'invalid_interaction' do
            expect { client.sound! }.to raise_error(RuntimeError, "401:Unauthorized")
          end
        end
      end
    end
  end
end
