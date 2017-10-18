module Deploy
  class CLI
    class DeploymentProgressOutput
      SERVER_TAG_COLOURS = %w[32 33 34 35 36].cycle

      attr_reader :deployment, :step_index, :server_tags

      def initialize(deployment)
        @deployment = deployment

        @step_index = @deployment.steps.each_with_object({}) { |s, hsh| hsh[s.identifier] = s }
        @server_tags = @deployment.servers.each_with_object({}) do |s, hsh|
          hsh[s.id] = "\e[#{SERVER_TAG_COLOURS.next};1m[#{s.name}]\e[0m "
        end
      end

      def monitor
        websocket_client = Deploy::CLI::WebsocketClient.new

        subscription = websocket_client.subscribe('deployment', @deployment.identifier)
        subscription.on('log-entry', &method(:handle_log_entry))
        subscription.on('status-change', &method(:handle_status_change))

        websocket_client.run
      end

      private

      def handle_log_entry(payload)
        step = step_index[payload['step']]
        server_tag = server_tags[step.server]

        line = "\n"
        line << server_tag if server_tag
        line << payload['message']

        if payload['detail']
          padding_width = 0
          padding_width += (server_tag.length - 11) if server_tag
          padding = ' ' * padding_width

          payload['detail'].split("\n").each do |detail_line|
            line << "\n#{padding}| #{detail_line}"
          end
        end

        STDOUT.print line
      end

      def handle_status_change(payload)
        if payload['status'] == 'completed'
          STDOUT.print "\nDeployment has finished successfully!\n"
        elsif payload['status'] == 'failed'
          STDOUT.print "\nDeployment has failed!\n"
        end

        throw(:finished) if %w[completed failed].include?(payload['status'])
      end
    end
  end
end
