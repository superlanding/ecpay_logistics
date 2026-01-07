require 'spec_helper'

RSpec.describe Hash do
  describe '#stringify_keys' do
    it 'converts all symbol keys to string keys' do
      hash = { name: 'John', age: 30, city: 'Taipei' }
      result = hash.stringify_keys

      expect(result.keys).to all(be_a(String))
      expect(result['name']).to eq('John')
      expect(result['age']).to eq(30)
      expect(result['city']).to eq('Taipei')
    end

    it 'preserves string keys as they are' do
      hash = { 'name' => 'Jane', 'age' => 25 }
      result = hash.stringify_keys

      expect(result).to eq({ 'name' => 'Jane', 'age' => 25 })
    end

    it 'handles mixed symbol and string keys' do
      hash = { name: 'Bob', 'age' => 35 }
      result = hash.stringify_keys

      expect(result.keys).to all(be_a(String))
      expect(result['name']).to eq('Bob')
      expect(result['age']).to eq(35)
    end

    it 'raises error when duplicate keys exist after conversion' do
      hash = { name: 'Alice', 'name' => 'Bob' }

      expect { hash.stringify_keys }.to raise_error(RuntimeError, /Duplicate key name/)
    end

    it 'returns a new hash without modifying the original' do
      original = { name: 'Charlie', age: 40 }
      result = original.stringify_keys

      expect(result).not_to equal(original)
      expect(original.keys.first).to be_a(Symbol)
    end

    it 'handles empty hash' do
      hash = {}
      result = hash.stringify_keys

      expect(result).to eq({})
    end

    it 'handles nested hashes' do
      hash = { user: { name: 'David', info: { age: 28 } } }
      result = hash.stringify_keys

      expect(result['user']).to be_a(Hash)
      expect(result['user'][:name]).to eq('David')
    end
  end
end
