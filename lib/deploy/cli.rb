require 'optparse'
require 'highline/import'
require 'deploy'

HighLine.colorize_strings

module Deploy
  class CLI

    ## Constants for formatting output
    TAP_COLOURS = {:info => :yellow, :error => :red, :success => :green}
    PROTOCOL_NAME = {:ssh => "SSH/SFTP", :ftp => "FTP", :s3 => "Amazon S3", :rackspace => "Rackspace CloudFiles"}

    class Config
      AVAILABLE_CONFIG = [:account, :username, :api_key, :project]

      def initialize(config_file=nil)
        @config_file_path = config_file || File.join(Dir.pwd, 'Deployfile')
        @config = JSON.parse(File.read(@config_file_path))
      rescue Errno::ENOENT => e
        puts "Couldn't find configuration file at #{@config_file_path}"
        exit 1
      end

      def method_missing(meth, *args, &block)
        if AVAILABLE_CONFIG.include?(meth.to_sym)
          @config[meth.to_s]
        else
          super
        end
      end
    end

    class << self

      def invoke(*args)
        options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: deployhq [command]"
          opts.on("-c", "--config", 'Configuration file path') do |v|
            options[:config_file] = v
          end
        end.parse!

        @configuration = Config.new(options[:config_file])
        Deploy.site = @configuration.account
        Deploy.email = @configuration.username
        Deploy.api_key = @configuration.api_key
        @project = Deploy::Project.find(@configuration.project)

        case args[0]
        when 'deploy'
          deploy
        when 'servers'
          server_list
        else
          puts "Usage: deployhq [command]"
          return
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
        @deployment = @project.deploy(parent.identifier, parent.last_revision, latest_revision)

        @server_names = @deployment.servers.each_with_object({}) do |server, hsh|
          hsh[server['id']] = server['name']
        end
        @longest_server_name = @server_names.values.map(&:length).max

        last_tap = nil
        current_status = 'pending'
        previous_status = ''
        print "Waiting for deployment capacity..."
        while ['running', 'pending'].include?(current_status) do
          sleep 1

          poll = @deployment.status_poll(:since => last_tap, :status => current_status)

          # Status only gets returned from the API if it has changed
          current_status = poll.status if poll.status

          if current_status == 'pending'
            print "."
          elsif current_status == 'running' && previous_status == 'pending'
            puts "\n"
          end

          if current_status != 'pending'
            poll.taps.each do |tap|
              puts format_tap(tap)
              last_tap = tap.id.to_i
            end
          end

          previous_status = current_status
        end
      end

      def deployment
        @deployment = @project.deployments.first
        @server_names = @deployment.servers.each_with_object({}) do |obj, hsh|
          hsh[obj.delete("id")] = obj["name"]
        end
        @longest_server_name = @server_names.values.map(&:length).max

        @deployment.taps.reverse.each do |tap|
          puts format_tap(tap)
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
          s << tap.message.color(text_colour)
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
