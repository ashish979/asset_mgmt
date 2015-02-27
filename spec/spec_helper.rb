# This file is copied to spec/ when you run 'rails generate rspec:install'
require "paperclip/matchers"
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# require 'rspec/autorun'
require 'simplecov-rcov'
if( ENV['COVERAGE'] == 'on' )
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
       SimpleCov::Formatter::HTMLFormatter.new.format(result)
       SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start 'rails' do
    add_filter "/vendor/"
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.alias_it_should_behave_like_to :it_should, 'should'
  config.include Paperclip::Shoulda::Matchers
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  
  config.include Devise::TestHelpers, :type => :controller
end

# RSpec matcher to spec delegations.
# Forked from https://gist.github.com/ssimeonov/5942729 with fixes
# for arity + custom prefix.
#
# Usage:
#
#     describe Post do
#       it { should delegate(:name).to(:author).with_prefix } # post.author_name
#       it { should delegate(:name).to(:author).with_prefix(:any) } # post.any_name
#       it { should delegate(:month).to(:created_at) }
#       it { should delegate(:year).to(:created_at) }
#       it { should delegate(:something).to(:'@instance_var') }
#     end
 
RSpec::Matchers.define :delegate do |method|
  match do |delegator|
    @method = @prefix ? :"#{@prefix}_#{method}" : method
    @delegator = delegator
 
    if @to.to_s[0] == '@'
      # Delegation to an instance variable
      old_value = @delegator.instance_variable_get(@to)
      begin
        @delegator.instance_variable_set(@to, receiver_double(method))
        @delegator.send(@method) == :called
      ensure
        @delegator.instance_variable_set(@to, old_value)
      end
    elsif @delegator.respond_to?(@to, true)
      unless [0,-1].include?(@delegator.method(@to).arity)
        raise "#{@delegator}'s' #{@to} method does not have zero or -1 arity (it expects parameters)"
      end
      @delegator.stub(@to).and_return receiver_double(method)
      @delegator.send(@method) == :called
    else
      raise "#{@delegator} does not respond to #{@to}"
    end
  end
 
  description do
    "delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end
 
  failure_message_for_should do |text|
    "expected #{@delegator} to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end
 
  failure_message_for_should_not do |text|
    "expected #{@delegator} not to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end
 
  chain(:to) { |receiver| @to = receiver }
  chain(:with_prefix) { |prefix| @prefix = prefix || @to }
 
  def receiver_double(method)
    double('receiver').tap do |receiver|
      receiver.stub(method).and_return :called
    end
  end
end