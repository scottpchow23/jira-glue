# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require 'net/https'
require 'jira'

module JIRA
  class Wrapper
    
    JIRA_BASE_URL       = ENV["jira_base_url"] or raise "jira_base_url ENV not set"
    JIRA_CLIENT_OPTIONS = {
        :username        => (ENV["jira_username"] or raise "jira_username ENV not set"),
        :password        => (ENV["jira_password"] or raise "jira_password ENV not set"),
        :site            => JIRA_BASE_URL,
        :context_path    => "",
        :auth_type       => :basic,
        :use_ssl         => true,
        :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
    }

    def initialize()
      @jira_client = JIRA::Client.new(JIRA_CLIENT_OPTIONS)
    end
    
    def find_issue(key)
      begin  
        issue = @jira_client.Issue.find(key)
      rescue JIRA::HTTPError => ex
        if ex.message == "Unauthorized"
          puts "Unauthorized: please check that jira_username and jira_password are correctly set as ENV variables"
        else
          puts ex.message
        end
        nil
      end
    end
    
    def get_issue_description_and_link(key)
      if issue = find_issue(key)
        summary = issue.fields['summary']
        link    = "#{JIRA_BASE_URL}/issues/#{key}"

        [summary, link]
      else
        raise "Could not get issue from key: #{key}"
      end
    end
  end
end