require 'spec_helper'
require 'open3'
require 'rbconfig'

RSpec.describe 'cgi/escape usage' do
  let(:helper) { ECpayLogistics::APIHelper.new }

  it 'urlencodes in .NET style' do
    expect(helper.urlencode_dot_net('a b!*()&=中')).to eq('a+b!*()%26%3d%e4%b8%ad')
  end

  it 'does not load the removed CGI library' do
    lib = File.expand_path('../lib', __dir__)
    _out, err, _status = Open3.capture3(RbConfig.ruby, '-W', "-I#{lib}", '-e', 'require "ecpay_logistics"')
    expect(err).not_to include('CGI library is removed')
  end

  it 'provides CGI.escape' do
    expect(CGI.respond_to?(:escape)).to be true
  end
end
