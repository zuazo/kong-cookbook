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

require_relative '../spec_helper'
require 'kong_service_provider'

describe KongCookbook::KongServiceProvider, order: :random do
  let(:node) do
    node = Chef::Node.new
    node.set['platform_family'] = 'debian'
    node.set['platform'] = 'debian'
    node.set['platform_version'] = '8.0'
    Dir.glob("#{::File.dirname(__FILE__)}/../../../attributes/*.rb") do |f|
      node.from_file(f)
    end
    node
  end
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:new_resource) { Chef::Resource::Service.new('kong', run_context) }
  let(:provider) do
    KongCookbook::KongServiceProvider.new(new_resource, run_context)
  end
  let(:shellout) { instance_double('Mixlib::ShellOut') }
  let(:proc_status) { instance_double('Process::Status') }
  let(:shellout) { instance_double('Mixlib::ShellOut') }
  before do
    allow(shellout).to receive(:run_command).and_return(shellout)
    allow(shellout).to receive(:status).and_return(proc_status)
    allow(proc_status).to receive(:success?).and_return(true)
  end

  it 'is a Init Service' do
    expect(provider)
      .to be_a(Chef::Provider::Service::Init)
  end

  context '#initialize' do
    it 'calls parent constructor' do
      expect(Chef::Provider::Service::Init).to receive(:new)
      provider
    end

    it 'sets init command to kong' do
      expect(provider.init_command).to eq('kong')
    end

    context 'in resource supported actions' do
      supports = { restart: true, reload: true, status: true }

      supports.each do |action, supported|
        it "#{action} action support is #{supported}" do
          provider
          expect(new_resource.supports[action]).to eq(supported)
        end
      end # supports each
    end # context in resource supported actions

    it 'sets status command to kill -0 PID' do
      provider
      expect(new_resource.status_command)
        .to eq('kill -0 $(cat /usr/local/kong/nginx.pid)')
    end
  end # context #initialize

  context '#kong_supports_action?' do
    let(:action) { 'action' }
    let(:cmd) { "'kong' | grep -F #{action}" }
    before do
      allow(provider).to receive(:shell_out).with(cmd).and_return(shellout)
    end

    it 'checks if the action is supported' do
      expect(provider).to receive(:shell_out).with(cmd).once
        .and_return(shellout)
      expect(provider.kong_supports_action?(action))
    end

    it 'returns mixlib shellout result' do
      expect(proc_status).to receive(:success?).once.and_return('success')
      expect(provider.kong_supports_action?(action)).to eq('success')
    end
  end # context #kong_supports_action?

  context '#all_actions_requirements' do
    let(:cmd) { "which 'kong'" }
    before do
      allow(provider).to receive(:shell_out).with(cmd).and_return(shellout)
      %w(start stop restart reload).each do |action|
        allow(provider).to receive(:shell_out)
          .with("'kong' | grep -F #{action}").and_return(shellout)
      end
    end

    it 'does not raise any error if kong is found' do
      allow(provider).to receive(:shell_out).with(cmd).and_return(shellout)
      expect(shellout.status).to receive(:success?).and_return(true)
      provider.action = :start
      provider.define_resource_requirements
      provider.process_resource_requirements
    end

    it 'raises an error if kong is not found' do
      allow(provider).to receive(:shell_out).with(cmd).and_return(shellout)
      expect(shellout.status).to receive(:success?).and_return(false)
      provider.action = :start
      provider.define_resource_requirements
      expect { provider.process_resource_requirements }
        .to raise_error(Chef::Exceptions::Service, /does not exist/)
    end
  end # context #all_actions_requirements

  context '#actions_requirements' do
    before do
      allow(provider).to receive(:shell_out).with("which 'kong'")
        .and_return(shellout)
      [:start, :stop, :restart, :reload].each do |action|
        allow(provider).to receive(:kong_supports_action?).with(action)
          .and_return(true)
      end
    end

    [:start, :stop, :restart, :reload].each do |action|
      it "does not raise any error if #{action} action is supported" do
        expect(provider).to receive(:kong_supports_action?).with(action)
          .and_return(true)
        provider.action = action
        provider.define_resource_requirements
        provider.process_resource_requirements
      end

      it "raises an error if #{action} action is not supported" do
        expect(provider).to receive(:kong_supports_action?).with(action)
          .and_return(false)
        provider.action = action
        provider.define_resource_requirements
        expect { provider.process_resource_requirements }
          .to raise_error(
            Chef::Exceptions::Service, /kong command does not support #{action}/
          )
      end
    end
  end # context #actions_requirements

  context '#define_resource_requirements' do
    before do
      allow(provider).to receive(:shared_resource_requirements)
      allow(provider).to receive(:all_actions_requirements)
      allow(provider).to receive(:actions_requirements)
    end

    it 'calls #shared_resource_requirements' do
      expect(provider).to receive(:shared_resource_requirements).once
      provider.define_resource_requirements
    end

    it 'calls #all_actions_requirements' do
      expect(provider).to receive(:all_actions_requirements).once
      provider.define_resource_requirements
    end

    it 'calls #actions_requirements' do
      expect(provider).to receive(:actions_requirements).once
      provider.define_resource_requirements
    end
  end # context #define_resource_requirements

  context '#ulimit_nofile' do
    let(:default_nofile) { [1024, 1025] }
    before do
      @cur_nofile = default_nofile
      allow(Process).to receive(:getrlimit).and_call_original
      allow(Process).to receive(:getrlimit).with(Process::RLIMIT_NOFILE)
        .and_return(default_nofile)
      allow(Process).to receive(:setrlimit).and_call_original
      allow(Process).to receive(:setrlimit)
        .with(Process::RLIMIT_NOFILE, anything, anything) do |_res, lim1, lim2|
          @cur_nofile = [lim1, lim2]
        end
    end

    it 'returns current nofiles limit' do
      expect(provider.ulimit_nofile).to eq(default_nofile)
    end

    it 'sets nofiles limit' do
      new_nofile = [4096, 4097]
      provider.ulimit_nofile(new_nofile)
      expect(@cur_nofile).to eq(new_nofile)
    end

    it 'prints a warning if an exception is thrown' do
      allow(Process).to receive(:setrlimit)
        .with(Process::RLIMIT_NOFILE, anything, anything)
        .and_raise(Errno::EPERM)
      allow(Chef::Log).to receive(:warn)
      expect(Chef::Log).to receive(:warn).with(/Cannot change open files limit/)
        .once
      provider.ulimit_nofile([1, 2])
    end
  end # context #ulimimt_nofile

  context '#ulimit_nofile_minimum' do
    let(:default_nofile) { [1024, 1024] }
    before do
      allow(provider).to receive(:ulimit_nofile).with(no_args)
        .and_return(default_nofile)
    end

    it 'changes nofile limit' do
      new_limit = 4096
      expect(provider).to receive(:ulimit_nofile).with([new_limit, new_limit])
        .once
      provider.ulimit_nofile_minimum(new_limit)
    end

    it 'does not change nofile limit if it is higher' do
      expect(provider).to receive(:ulimit_nofile).with(no_args).once
      provider.ulimit_nofile_minimum(512)
    end
  end # context #ulimit_nofile_minimum

  context '#run_within_ulimit' do
    let(:default_ulimit) { [1024, 1024] }
    before do
      @cur_ulimit = default_ulimit
      allow(provider).to receive(:ulimit_nofile).with(no_args)
        .and_return(default_ulimit)
      allow(provider).to receive(:ulimit_nofile).with(anything) do |new_ulimit|
        @cur_ulimit = new_ulimit
      end
    end

    it 'runs the block with a different ulimit' do
      def call_once; end
      expect(self).to receive(:call_once).once
      expect(@cur_ulimit).to eq(default_ulimit)
      provider.run_within_ulimit do
        call_once
        expect(@cur_ulimit).to eq([4096, 4096])
      end
      expect(@cur_ulimit).to eq(default_ulimit)
    end

    it 'returns the block result' do
      result = provider.run_within_ulimit { 'result' }
      expect(result).to eq('result')
    end
  end # context #run_within_ulimit

  %w(start restart).each do |action|
    context "##{action}_service" do
      before do
        allow_any_instance_of(provider.class.superclass)
          .to receive("#{action}_service")
        allow(provider).to receive(:ulimit_nofile_minimum)
        allow(provider).to receive(:ulimit_nofile)
      end

      it 'calls #run_within_ulimit' do
        expect(provider).to receive(:run_within_ulimit).once
        provider.send("#{action}_service")
      end

      it 'calls the parent implementation' do
        expect_any_instance_of(provider.class.superclass)
          .to receive("#{action}_service").once
        provider.send("#{action}_service")
      end
    end # context #action_service
  end # each action
end
