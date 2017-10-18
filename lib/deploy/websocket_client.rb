require 'websocket-eventmachine-client'
require 'logger'

module Deploy
  # Manages a connection and associated subscriptions to DeployHQ's websocket
  class WebsocketClient
    attr_reader :subscriptions

    class Subscription
      attr_reader :exchange, :routing_key

      def initialize(exchange, routing_key)
        @exchange = exchange
        @routing_key = routing_key
        @events = {}
      end

      def on(event, &block)
        @events[event] ||= []
        @events[event] << block
      end

      def dispatch(event, payload)
        return unless @events[event]

        @events[event].each do |block|
          block.call(payload)
        end
      end

      def subscribed?
        @subscribed == true
      end

      def subscribed!
        @subscribed = true
      end
    end

    def initialize
      @subscriptions = {}
    end

    def subscribe(exchange, routing_key)
      key = subscription_key(exchange, routing_key)
      subscriptions[key] ||= Subscription.new(exchange, routing_key)
    end

    def run
      catch(:finished) do
        EM.run do
          connection.onopen do
            logger.info "connected"
          end

          connection.onmessage do |msg, type|
            receive(msg)
          end

          connection.onclose do |code, reason|
            logger.info "disconnected #{code} #{reason}"
            reset_connection
          end
        end
      end
    end

    private

    def dispatch(event, payload, mq = nil)
      case event
      when 'Welcome'
        authenticate
      when 'Authenticated'
        request_subscriptions
      when 'Subscribed'
        successful_subscription(payload)
      when 'Error'
        websocket_error(payload)
      else
        subscription_event(event, payload, mq) if mq
      end
    end

    def authenticate
      # TODO: hardcoded session ID probably not a good method of auth
      send('Authenticate', session_id: "ycbckLWbFfqxsR7IyVeZRdfUczGXRMxSz/DBmROSYPQ=")
    end

    def request_subscriptions
      subscriptions.each do |_key, subscription|
        send('Subscribe', exchange: subscription.exchange, routing_key: subscription.routing_key)
      end
    end

    def successful_subscription(payload)
      key = subscription_key(payload['exchange'], payload['routing_key'])
      subscription = subscriptions[key]
      subscription.subscribed! if subscription
    end

    def websocket_error(payload)
      raise Deploy::Errors::WebsocketError, payload['error']
    end

    def subscription_event(event, payload, mq)
      key = subscription_key(mq["e"], mq["rk"])
      subscription = subscriptions[key]
      subscription.dispatch(event, payload) if subscription
    end

    def receive(msg)
      logger.debug "< #{msg}"
      decoded = JSON.parse(msg)
      dispatch(decoded['event'], decoded['payload'], decoded['mq'])
    end

    def send(action, payload = {})
      msg = JSON.dump(action: action, payload: payload)
      logger.debug "> #{msg}"
      connection.send(msg)
    end

    def connection
      @connection ||= WebSocket::EventMachine::Client.connect(uri: 'ws://test.deploy.dev:8080/pushwss')
    end

    def reset_connection
      @connection = nil
    end

    def logger
      @logger ||= Logger.new(STDOUT)
      @logger.level = Logger::ERROR
      @logger
    end

    def subscription_key(exchange, routing_key)
      [exchange, routing_key].join('-')
    end
  end
end
