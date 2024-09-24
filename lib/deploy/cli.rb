# frozen_string_literal: true

require 'optparse'
require 'highline/import'

require 'deploy'
require 'deploy/cli/websocket_client'
require 'deploy/cli/deployment_progress_output'

OptionsStruct = Struct.new(:config_file, :project, :config_files_deployment)

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
module Deploy
  class CLI

    ## Constants for formatting output
    PROTOCOL_NAME = { ssh: 'SSH/SFTP', ftp: 'FTP', s3: 'Amazon S3', rackspace: 'Rackspace CloudFiles' }.freeze

    class << self

      def invoke(args)
        @options = OptionsStruct.new

        parser = OptionParser.new do |opts|
          opts.banner = 'Usage: deployhq [options] command'
          opts.separator ''
          opts.separator 'Commands:'
          opts.separator "deploy\t\t Start a new deployment"
          opts.separator "servers\t\t List configured servers and server groups"
          opts.separator "configure\t\t Create a new configuration file for this tool"
          opts.separator ''
          opts.separator 'Common Options:'

          @options.config_file = './Deployfile'
          opts.on('-c', '--config path', 'Configuration file path') do |config_file_path|
            @options.config_file = config_file_path
          end

          opts.on('-p', '--project project',
                  'Project to operate on (default is read from project: in config file)') do |project_permalink|
            @options.project = project_permalink
          end

          @options.config_files_deployment = false
          opts.on('--config-files', 'Config files deployment') do |_config_files_deployment|
            @options.config_files_deployment = true
          end

          opts.on_tail('-v', '--version', 'Shows Version') do
            puts Deploy::VERSION
            exit
          end

          opts.on_tail('-h', '--help', 'Displays Help') do
            puts opts
            exit
          end
        end

        begin
          parser.parse!(args)
          command = args.pop
        rescue OptionParser::InvalidOption
          warn parser
          exit 1
        end

        unless command == 'configure'
          begin
            Deploy.configuration_file = @options.config_file
          rescue Errno::ENOENT
            warn "Couldn't find configuration file at #{@options.config_file.inspect}"
            exit 1
          end

          project_permalink = @options.project || Deploy.configuration.project
          if project_permalink.nil?
            warn 'Project must be specified in config file or as --project argument'
            exit 1
          end

          @project = Deploy::Project.find(project_permalink)
        end

        case command
        when 'deploy'
          deploy
        when 'servers'
          server_list
        when 'configure'
          configure
        else
          warn parser
        end
      end

      def server_list
        @server_groups ||= @project.server_groups
        if @server_groups.count.positive?
          @server_groups.each do |group|
            puts "Group: #{group.name}"
            puts group.servers.map { |server| format_server(server) }.join("\n\n")
          end
        end

        @ungrouped_servers ||= @project.servers
        return unless @ungrouped_servers.count.positive?

        puts "\n" if @server_groups.count.positive?
        puts 'Ungrouped Servers'
        puts @ungrouped_servers.map { |server| format_server(server) }.join("\n\n")
      end

      def deploy
        @ungrouped_servers = @project.servers
        @server_groups = @project.server_groups

        parent = nil
        while parent.nil?
          parent = choose do |menu|
            menu.prompt = 'Please choose a server or group to deploy to:'

            menu.choices(*(@ungrouped_servers + @server_groups))
            menu.choice('List Server Details') do
              server_list
              nil
            end
          end
        end

        if @options.config_files_deployment
          deployment = @project.config_files_deployment(parent.identifier)
        else
          latest_revision = @project.latest_revision(parent.preferred_branch)
          deployment = @project.deploy(parent.identifier, parent.last_revision, latest_revision)
        end

        $stdout.print 'Waiting for an available deployment slot...'
        DeploymentProgressOutput.new(deployment).monitor
      end

      def configure
        configuration = {
          account: ask_config_question('Account Domain (e.g. https://atech.deployhq.com)',
                                       /\Ahttps?:\/\/[a-z0-9.-]+.deployhq.com\z/),
          username: ask_config_question('Username or e-mail address'),
          api_key: ask_config_question('API key (You can find this in Settings -> Security)'),
          project: ask_config_question('Default project to use (please use permalink from web URL)')
        }

        confirmation = true
        if File.exist?(@options.config_file)
          confirmation = agree("File already exists at #{@options.config_file}. Overwrite? ")
        end

        return unless confirmation

        file_data = JSON.pretty_generate(configuration)
        File.write(@options.config_file, file_data)
        say("File written to #{@options.config_file}")
      end

      def ask_config_question(question_text, valid_format = /.+/)
        question_text = "#{question_text}: "
        ask(question_text) do |q|
          q.whitespace = :remove
          q.responses[:not_valid] = 'That answer is not valid'
          q.responses[:ask_on_error] = :question
          q.validate = valid_format
        end
      end

      private

      ## Data formatters
      def format_server(server)
        server_params = {
          'Name' => server.name,
          'Type' => PROTOCOL_NAME[server.protocol_type.to_sym],
          'Path' => server.server_path,
          'Branch' => server.preferred_branch,
          'Current Revision' => server.last_revision
        }
        server_params['Hostname'] = [server.hostname, server.port].join(':') if server.hostname
        server_params['Bucket'] = server.bucket_name if server.bucket_name
        server_params['Region'] = server.region if server.region
        server_params['Container'] = server.container_name if server.container_name

        [].tap do |a|
          a << format_kv_pair(server_params)
        end.join("\n")
      end

      # rubocop:disable Lint/FormatParameterMismatch
      def format_kv_pair(hash)
        longest_key = hash.keys.map(&:length).max + 2
        hash.each_with_index.map do |(k, v), _i|
          str = format("%#{longest_key}s : %s", k, v)
          str
        end.join("\n")
      end
      # rubocop:enable Lint/FormatParameterMismatch

    end

  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/PerceivedComplexity
