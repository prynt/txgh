require 'spec_helper'
require 'octokit'

describe Txgh do
  def with_env(env)
    # ENV can't be duped, so use select instead to make a copy
    old_env = ENV.select { true }
    env.each_pair { |k, v| ENV[k] = v }
    yield
  ensure
    # reset back to old vars
    env.each_pair { |k, _| ENV[k] = old_env[k] }
  end

  describe '#env' do
    it 'defaults to development' do
      expect(Txgh.env).to eq('development')
    end

    it 'pulls the env out of ENV if set' do
      with_env('TXGH_ENV' => 'production') do
        expect(Txgh.env).to eq('production')
      end
    end
  end

  describe 'providers' do
    it 'defaults to the raw tx config provider' do
      instance = Txgh.tx_manager.provider_for('foo')
      expect(instance.provider.scheme).to eq('raw')
    end
  end
end
