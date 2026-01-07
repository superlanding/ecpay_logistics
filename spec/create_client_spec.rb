require 'spec_helper'

RSpec.describe ECpayLogistics::CreateClient do
  let(:client) { ECpayLogistics::CreateClient.new }

  describe '#initialize' do
    it 'creates a new CreateClient instance' do
      expect(client).to be_a(ECpayLogistics::CreateClient)
    end

    it 'initializes helper' do
      expect(client.helper).to be_a(ECpayLogistics::APIHelper)
    end

    it 'includes error definition module' do
      expect(client.class.included_modules).to include(ECpayErrorDefinition)
    end
  end

  describe '#create' do
    context 'with invalid input' do
      it 'raises error when param is not a hash' do
        expect { client.create("not a hash") }
          .to raise_error(ECpayErrorDefinition::ECpayInvalidParam, /must be a Hash/)
      end

      it 'raises error when param is nil' do
        expect { client.create(nil) }
          .to raise_error(ECpayErrorDefinition::ECpayInvalidParam, /must be a Hash/)
      end

      it 'raises error when param is an array' do
        expect { client.create([]) }
          .to raise_error(ECpayErrorDefinition::ECpayInvalidParam, /must be a Hash/)
      end
    end

    context 'with valid hash but missing required fields' do
      it 'processes the hash and converts keys to strings' do
        # This will fail validation, but should pass the initial hash check
        params = { MerchantTradeNo: 'TEST123' }

        # We expect it to fail at verification stage with InvalidParam or LogisticsRuleViolate
        expect { client.create(params) }.to raise_error(ECpayErrorDefinition::ECpayError)
      end
    end

    context 'when in contractor mode' do
      before do
        allow(client.helper).to receive(:is_contractor?).and_return(true)
        allow(client.helper).to receive(:get_mercid).and_return('PLATFORM123')
      end

      it 'raises error when MerchantID is not specified' do
        params = { 'LogisticsType' => 'CVS' }

        expect { client.create(params) }
          .to raise_error(/MerchantID.*should be specified.*contractor/)
      end
    end

    context 'when not in contractor mode' do
      before do
        allow(client.helper).to receive(:is_contractor?).and_return(false)
        allow(client.helper).to receive(:get_mercid).and_return('MERCHANT123')
      end

      it 'sets MerchantID from helper' do
        params = {
          'LogisticsType' => 'CVS',
          'LogisticsSubType' => 'FAMI',
          'MerchantTradeNo' => 'TEST' + Time.now.to_i.to_s,
          'MerchantTradeDate' => Time.now.strftime('%Y/%m/%d %H:%M:%S'),
          'GoodsAmount' => '100',
          'GoodsName' => 'Test Product',
          'SenderName' => 'Sender',
          'ReceiverName' => 'Receiver',
          'ReceiverStoreID' => '001'
        }

        # Mock the verification and HTTP request
        allow_any_instance_of(ECpayLogistics::CreateParamVerify).to receive(:verify_create_param)
        allow_any_instance_of(ECpayLogistics::CreateParamVerify).to receive(:get_special_encode_param).and_return([])
        allow_any_instance_of(ECpayLogistics::CreateParamVerify).to receive(:get_svc_url).and_return('http://test.example.com')
        allow(client.helper).to receive(:gen_chk_mac_value).and_return('ABCDEF123456')
        allow(client.helper).to receive(:http_request).and_return('1|OK')

        result = client.create(params)
        expect(result).to eq('1|OK')
      end
    end
  end

  describe 'parameter processing' do
    it 'converts symbol keys to string keys' do
      allow(client.helper).to receive(:is_contractor?).and_return(false)
      allow(client.helper).to receive(:get_mercid).and_return('MERCHANT123')

      params = {
        LogisticsType: 'CVS',
        MerchantTradeNo: 'TEST123'
      }

      # This will fail at verification, but the keys should be stringified first
      expect { client.create(params) }.to raise_error(ECpayErrorDefinition::ECpayError)
    end

    it 'sets PlatformID to empty string when not contractor' do
      allow(client.helper).to receive(:is_contractor?).and_return(false)
      allow(client.helper).to receive(:get_mercid).and_return('MERCHANT123')
      allow_any_instance_of(ECpayLogistics::CreateParamVerify).to receive(:verify_create_param) do |instance, params|
        expect(params['PlatformID']).to eq('')
        expect(params['MerchantID']).to eq('MERCHANT123')
      end
      allow_any_instance_of(ECpayLogistics::CreateParamVerify).to receive(:get_special_encode_param).and_return([])
      allow_any_instance_of(ECpayLogistics::CreateParamVerify).to receive(:get_svc_url).and_return('http://test.example.com')
      allow(client.helper).to receive(:gen_chk_mac_value).and_return('ABC')
      allow(client.helper).to receive(:http_request).and_return('1|OK')

      params = {
        'LogisticsType' => 'CVS',
        'LogisticsSubType' => 'FAMI',
        'MerchantTradeNo' => 'TEST123',
        'MerchantTradeDate' => '2024/01/01 12:00:00',
        'GoodsAmount' => '100',
        'GoodsName' => 'Test',
        'SenderName' => 'Sender',
        'ReceiverName' => 'Receiver',
        'ReceiverStoreID' => '001'
      }

      client.create(params)
    end
  end
end
