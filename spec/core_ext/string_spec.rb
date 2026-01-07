require 'spec_helper'

RSpec.describe String do
  describe '#hashify' do
    it 'converts URL encoded string to hash' do
      str = "name=John&age=30&city=Taipei"
      result = str.hashify

      expect(result).to be_a(Hash)
      expect(result['name']).to eq('John')
      expect(result['age']).to eq('30')
      expect(result['city']).to eq('Taipei')
    end

    it 'handles URL encoded values' do
      str = "name=John%20Doe&message=Hello%20World"
      result = str.hashify

      expect(result['name']).to eq('John%20Doe')
      expect(result['message']).to eq('Hello%20World')
    end

    it 'handles empty values' do
      str = "name=&age=30&city="
      result = str.hashify

      expect(result['name']).to be_nil
      expect(result['age']).to eq('30')
      expect(result['city']).to be_nil
    end

    it 'handles single key-value pair' do
      str = "key=value"
      result = str.hashify

      expect(result).to eq({ 'key' => 'value' })
    end

    it 'handles Chinese characters with UTF-8 encoding' do
      str = "名稱=測試&城市=台北"
      result = str.hashify

      expect(result['名稱']).to eq('測試')
      expect(result['城市']).to eq('台北')
    end

    it 'handles empty string' do
      str = ""
      result = str.hashify

      expect(result).to be_a(Hash)
      expect(result).to be_empty
    end

    it 'handles special characters in values' do
      str = "CheckMacValue=ABC123&MerchantID=2000132"
      result = str.hashify

      expect(result['CheckMacValue']).to eq('ABC123')
      expect(result['MerchantID']).to eq('2000132')
    end
  end
end
