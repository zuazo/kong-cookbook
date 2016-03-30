# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015-2016 Xabier de Zuazo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative 'spec_helper'
require 'json'

def kong_pid
  File.read('/usr/local/kong/nginx.pid').chomp
end

def kong_limits_file
  "/proc/#{kong_pid}/limits"
end

def limit_value(str)
  Integer(str)
rescue
  nil
end

def kong_limits
  limits = File.read(kong_limits_file).split("\n")
  limits[1..-1].each_with_object({}) do |line, memo|
    line_ary = line.split(/[ ][ ]+/)
    limit_name = line_ary.shift
    limit_values = line_ary[0..1].map { |x| limit_value(x) }
    memo[limit_name] = limit_values
  end
end

describe 'kong' do
  describe port(8001) do
    it { should be_listening.with('tcp') }
  end

  it 'starts kong service' do
    expect(command("ps -p #{kong_pid}").exit_status).to be 0
  end

  context 'in resource limits' do
    it 'sets open files soft limit to 4096 or more' do
      expect(kong_limits['Max open files'][0]).to be >= 4096
    end

    it 'sets open files hard limit to 4096 or more' do
      expect(kong_limits['Max open files'][1]).to be >= 4096
    end
  end
end

describe server(:web) do
  describe http('http://127.0.0.1:8001/') do
    let(:body_json) { JSON.parse(response.body) }

    it 'returns a JSON body' do
      expect { body_json }.to_not raise_error
    end

    it 'does not return an error' do
      expect(body_json['message']).to_not match(/[Ee]rror/)
    end

    it 'returns Kong tagline' do
      expect(body_json['tagline']).to include('Kong')
    end

    it 'returns Kong version' do
      expect(body_json['version']).to be_a(String)
    end
  end # http /
end # server web
