require 'optparse'
require 'highline/import'

require 'deploy'
require 'deploy/cli/websocket_client'
require 'deploy/cli/deployment_progress_output'

HighLine.colorize_strings

module Deploy
  class CLI
    ## Constants for formatting output
    PROTOCOL_NAME = {:ssh => "SSH/SFTP", :ftp => "FTP", :s3 => "Amazon S3", :rackspace => "Rackspace CloudFiles"}

    class << self
      def invoke(args)
        options = OpenStruct.new
        options.config_file = './Deployfile'

        parser = OptionParser.new do |opts|
          opts.banner = "Usage: deployhq [options] command"
          opts.separator ""
          opts.separator "Commands:"
          opts.separator "deploy\t\t Start a new deployment"
          opts.separator "servers\t\t List configured servers and server groups"
          opts.separator ""
          opts.separator "Common Options:"

          options.config_file = './Deployfile'
          opts.on("-c", "--config path", 'Configuration file path') do |config_file_path|
            options.config_file = config_file_path
          end

          opts.on("-p", "--project project",
            "Project to operate on (default is read from project: in config file)") do |project_permalink|
            options.project = project_permalink
          end

          opts.on_tail('-v', '--version', "Shows Version") do
            puts Deploy::VERSION
            exit
          end

          opts.on_tail("-h", "--help", "Displays Help") do
            puts opts
            exit
          end
        end

        begin
          parser.parse!(args)
        rescue OptionParser::InvalidOption
          STDERR.puts parser.to_s
          exit 1
        end

        begin
          Deploy.configuration_file = options.config_file
        rescue Errno::ENOENT
          STDERR.puts "Couldn't find configuration file at #{options.config_file.inspect}"
          exit 1
        end

        project_permalink = options.project || Deploy.configuration.project
        if project_permalink.nil?
          STDERR.puts "Project must be specified in config file or as --project argument"
          exit 1
        end

        @project = Deploy::Project.find(project_permalink)

        case args.pop
        when 'deploy'
          deploy
        when 'servers'
          server_list
        else
          STDERR.puts parser.to_s
        end
      end

      def server_list
        @server_groups ||= @project.server_groups
        if @server_groups.count > 0
          @server_groups.each do |group|
            puts "Group: #{group.name}".bold
            puts group.servers.map {|server| format_server(server) }.join("\n\n")
          end
        end

        @ungrouped_servers ||= @project.servers
        if @ungrouped_servers.count > 0
          puts "\n" if @server_groups.count > 0
          puts "Ungrouped Servers".bold
          puts @ungrouped_servers.map {|server| format_server(server) }.join("\n\n")
        end
      end

      def deploy
        @ungrouped_servers = @project.servers
        @server_groups = @project.server_groups

        parent = nil
        while parent.nil?
          parent = choose do |menu|
            menu.prompt = "Please choose a server or group to deploy to:"

            menu.choices(*(@ungrouped_servers + @server_groups))
            menu.choice("List Server Details") do
              server_list
              nil
            end
          end
        end

        latest_revision = @project.latest_revision(parent.preferred_branch)
        deployment = @project.deploy(parent.identifier, parent.last_revision, latest_revision)

        STDOUT.print "Waiting for an available deployment slot..."
        DeploymentProgressOutput.new(deployment).monitor
      end

      def deployment
        @deployment = @project.deployments.first
        @server_names = @deployment.servers.each_with_object({}) do |obj, hsh|
          hsh[obj.delete("id")] = obj["name"]
        end
        @longest_server_name = @server_names.values.map(&:length).max

        @deployment.taps.reverse.each do |tap|
          STDOUT.puts format_tap(tap)
        end
      end

      ## Data formatters

      def format_tap(tap)
        server_name = @server_names[tap.server_id]

        if server_name
          padding = (@longest_server_name - server_name.length) / 2.0
          server_name = "[#{' ' * padding.ceil} #{server_name} #{' ' * padding.floor}]"
        else
          server_name = ' '
        end

        text_colour = TAP_COLOURS[tap.tap_type.to_sym] || :white

        String.new.tap do |s|
          s << "#{server_name} ".color(text_colour, :bold)
          s << tap.message.color(text_colour).gsub(/\<[^\>]*\>/, '')
          if tap.backend_message && tap.tap_type == 'command'
            tap.backend_message.each_line('<br />') do |backend_line|
              s << "\n"
              s << " " * server_name.length
              s << "   "
              s << backend_line.color(text_colour).gsub(/\<[^\>]*\>/, '')
            end
          end
          s << "\n"
        end
      end

      def format_server(server)
        server_params = {
          "Name" => server.name,
          "Type" => PROTOCOL_NAME[server.protocol_type.to_sym],
          "Path" => server.server_path,
          "Branch" => server.preferred_branch,
          "Current Revision" => server.last_revision,
        }
        server_params["Hostname"] = [server.hostname, server.port].join(':') if server.hostname
        server_params["Bucket"] = server.bucket_name if server.bucket_name
        server_params["Region"] = server.region if server.region
        server_params["Container"] = server.container_name if server.container_name

        Array.new.tap do |a|
          a << format_kv_pair(server_params)
        end.join("\n")
      end

      def format_kv_pair(hash)
        longest_key = hash.keys.map(&:length).max + 2
        hash.each_with_index.map do |(k,v), i|
          str = sprintf("%#{longest_key}s : %s", k,v)
          i == 0 ? str.color(:bold) : str
        end.join("\n")
      end

    end
  end
end
