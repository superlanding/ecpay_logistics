require 'spec_helper'

RSpec.describe ECpayLogistics::APIHelper do
  let(:helper) { ECpayLogistics::APIHelper.new }

  describe '#get_mercid' do
    it 'returns merchant ID' do
      expect(helper.get_mercid).not_to be_nil
      expect(helper.get_mercid).to be_a(String)
    end
  end

  describe '#get_merc_tra_date' do
    it 'returns merchant transaction date in correct format' do
      date = helper.get_merc_tra_date
      expect(date).to match(/\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}/)
    end
  end

  describe '#get_op_mode' do
    it 'returns operation mode' do
      mode = helper.get_op_mode
      expect(mode).not_to be_nil
      expect(['Test', 'Production']).to include(mode)
    end
  end

  describe '#get_curr_unixtime' do
    it 'returns current unix timestamp' do
      time = helper.get_curr_unixtime
      expect(time).to be_a(Integer)
      expect(time).to be > 0
    end

    it 'returns different values when called multiple times' do
      time1 = helper.get_curr_unixtime
      sleep(0.1)
      time2 = helper.get_curr_unixtime
      expect(time2).to be >= time1
    end
  end

  describe '#is_contractor?' do
    it 'returns boolean value' do
      result = helper.is_contractor?
      expect([true, false]).to include(result)
    end
  end

  describe '#urlencode_dot_net' do
    context 'with valid string' do
      it 'URL encodes a string in .NET compatible format' do
        result = helper.urlencode_dot_net("Hello World")
        expect(result).to eq("hello+world")
      end

      it 'handles special characters' do
        result = helper.urlencode_dot_net("test@example.com")
        expect(result).to match(/test%40example\.com/)
      end

      it 'preserves .NET special characters (!*())' do
        result = helper.urlencode_dot_net("test(!)test*")
        expect(result).to include('!')
        expect(result).to include('*')
        expect(result).to include('(')
        expect(result).to include(')')
      end

      it 'converts to uppercase when case_tr is UP' do
        result = helper.urlencode_dot_net("hello", case_tr: 'UP')
        expect(result).to eq("HELLO")
      end

      it 'keeps case when case_tr is KEEP' do
        result = helper.urlencode_dot_net("HeLLo", case_tr: 'KEEP')
        expect(result).to eq("HeLLo")
      end

      it 'converts to lowercase by default' do
        result = helper.urlencode_dot_net("HELLO")
        expect(result).to eq("hello")
      end
    end

    context 'with invalid input' do
      it 'raises error when input is not a string' do
        expect { helper.urlencode_dot_net(123) }.to raise_error(/not a string/)
      end

      it 'raises error when input is nil' do
        expect { helper.urlencode_dot_net(nil) }.to raise_error(/not a string/)
      end
    end
  end

  describe '#encode_special_param!' do
    it 'encodes specified parameters in hash' do
      params = { 'ReceiverName' => '測試', 'MerchantID' => '12345' }
      helper.encode_special_param!(params, ['ReceiverName'])

      expect(params['ReceiverName']).not_to eq('測試')
      expect(params['MerchantID']).to eq('12345')
    end

    it 'handles empty target array' do
      params = { 'Name' => 'Test' }
      original = params.dup
      helper.encode_special_param!(params, [])

      expect(params).to eq(original)
    end

    it 'skips parameters not in target array' do
      params = { 'Name' => 'Test', 'Value' => '123' }
      helper.encode_special_param!(params, ['NonExistent'])

      expect(params['Name']).to eq('Test')
      expect(params['Value']).to eq('123')
    end
  end

  describe '#gen_chk_mac_value' do
    let(:test_params) { { 'MerchantID' => '2000132', 'Amount' => '100' } }

    it 'generates SHA256 checksum by default (mode: 1)' do
      checksum = helper.gen_chk_mac_value(test_params, mode: 1)
      expect(checksum).to be_a(String)
      expect(checksum.length).to eq(64) # SHA256 produces 64 hex characters
      expect(checksum).to match(/^[A-F0-9]+$/)
    end

    it 'generates MD5 checksum when mode is 0' do
      checksum = helper.gen_chk_mac_value(test_params, mode: 0)
      expect(checksum).to be_a(String)
      expect(checksum.length).to eq(32) # MD5 produces 32 hex characters
      expect(checksum).to match(/^[A-F0-9]+$/)
    end

    it 'raises error when params contain CheckMacValue' do
      invalid_params = test_params.merge('CheckMacValue' => 'test')
      expect { helper.gen_chk_mac_value(invalid_params) }
        .to raise_error(/shouldn't contain CheckMacValue/)
    end

    it 'raises error when params contain HashKey' do
      invalid_params = test_params.merge('HashKey' => 'test')
      expect { helper.gen_chk_mac_value(invalid_params) }
        .to raise_error(/shouldn't contain HashKey/)
    end

    it 'raises error when params contain HashIV' do
      invalid_params = test_params.merge('HashIV' => 'test')
      expect { helper.gen_chk_mac_value(invalid_params) }
        .to raise_error(/shouldn't contain HashIV/)
    end

    it 'raises error when input is not a hash' do
      expect { helper.gen_chk_mac_value("not a hash") }
        .to raise_error(/not a Hash/)
    end

    it 'raises error when mode is invalid' do
      expect { helper.gen_chk_mac_value(test_params, mode: 99) }
        .to raise_error(/Unexpected hash mode/)
    end

    it 'produces consistent checksum for same parameters' do
      checksum1 = helper.gen_chk_mac_value(test_params)
      checksum2 = helper.gen_chk_mac_value(test_params)
      expect(checksum1).to eq(checksum2)
    end

    it 'produces different checksums for different parameters' do
      params1 = { 'MerchantID' => '2000132', 'Amount' => '100' }
      params2 = { 'MerchantID' => '2000132', 'Amount' => '200' }

      checksum1 = helper.gen_chk_mac_value(params1)
      checksum2 = helper.gen_chk_mac_value(params2)

      expect(checksum1).not_to eq(checksum2)
    end
  end

  describe '#http_request' do
    it 'raises error for unsupported HTTP method' do
      expect {
        helper.http_request(method: 'DELETE', url: 'http://example.com', payload: {})
      }.to raise_error(ArgumentError, /Only GET & POST method/)
    end
  end
end
