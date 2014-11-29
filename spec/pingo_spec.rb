require 'spec_helper'

describe Pingo do
  it 'has a version number' do
    expect(Pingo::VERSION).not_to be_nil
  end

  describe "#request_partition" do
    subject { Pingo::Pingo.new("5s") }

    context 'valid APPLE_ID and APPLE_PASSWORD in ENV' do
      before { set_valid_env }

      it 'should return partition' do
        VCR.use_cassette 'init_client/partition/valid_interaction' do
          expect(subject.send(:request_partition)).not_to be_nil
        end
      end
    end

    context 'invalid APPLE_ID and APPLE_PASSWORD in ENV' do
      before { set_invalid_env }

      it 'should not return partition' do
        VCR.use_cassette 'init_client/partition/invalid_interaction' do
          expect(subject.send(:request_partition)).to be_nil
        end
      end
    end
  end

  describe "#request_device_ids" do
    before { set_valid_env }
    let!(:pingo) { Pingo::Pingo.new(model_name) }

    context 'valid model_name' do
      let(:model_name) { "5s" }

      it 'should return device_id' do
        VCR.use_cassette 'init_client/partition/valid_interaction' do
          partition = pingo.send(:request_partition)

          VCR.use_cassette 'init_client/device_id/valid_interaction' do
            expect(pingo.send(:request_device_ids, partition)).not_to be_nil
          end
        end
      end
    end

    context 'invalid model_name' do
      let(:model_name) { "9s" }

      it 'should not return device_id' do
        VCR.use_cassette 'init_client/partition/valid_interaction' do
          partition = pingo.send(:request_partition)

          VCR.use_cassette 'init_client/device_id/invalid_interaction' do
            expect(pingo.send(:request_device_ids, partition)).to eq([])
          end
        end
      end
    end
  end

  describe "#request_sound" do
    before { set_valid_env }
    let!(:pingo) { Pingo::Pingo.new("5s") }

    context 'valid device_id' do
      it 'should return 200 of status code' do
        VCR.use_cassette 'init_client/partition/valid_interaction' do
          partition = pingo.send(:request_partition)

          VCR.use_cassette 'init_client/device_id/valid_interaction' do
            device_ids = pingo.send(:request_device_ids, partition)

            VCR.use_cassette 'play_sound/valid_interaction' do
              responses = pingo.send(:request_sound, partition, device_ids)

              responses.each do |response|
                # VCR response structure and typhoeus it are differ even
                expect([response.code, response.response_code]).to include(200)
              end
            end
          end
        end
      end
    end

    context 'invalid device_id' do
      let!(:device_ids) { "invalid device id" }

      it 'should return 500 of status code' do
        VCR.use_cassette 'init_client/partition/valid_interaction' do
          partition = pingo.send(:request_partition)

          VCR.use_cassette 'init_client/device_id/valid_interaction' do
            pingo.send(:request_device_ids, partition)

            VCR.use_cassette 'play_sound/invalid_interaction' do
              responses = pingo.send(:request_sound, partition, device_ids)

              responses.each do |response|
                # VCR response structure and typhoeus it are differ even
                expect([response.code, response.response_code]).to include(500)
              end
            end
          end
        end
      end
    end
  end
end
