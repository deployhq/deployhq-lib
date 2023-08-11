# frozen_string_literal: true

require 'websocket-eventmachine-client'
require 'logger'

module Deploy
  class CLI

    # Manages a connection and associated subscriptions to DeployHQ's websocket
    class WebsocketClient

      attr_reader :subscriptions

      class Subscription

        attr_reader :exchange
        attr_reader :routing_key

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
              logger.info 'connected'
            end

            connection.onmessage do |msg, _type|
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

      def dispatch(event, payload, rmq = nil)
        case event
        when 'Welcome'
          authenticate
        when 'Authenticated'
          request_subscriptions
        when 'Subscribed'
          successful_subscription(payload)
        when 'Error', 'InternalError'
          websocket_error(payload)
        else
          subscription_event(event, payload, rmq) if rmq
        end
      end

      def authenticate
        send('Authenticate', api_key: Deploy.configuration.api_key)
      end

      def request_subscriptions
        subscriptions.each do |_key, subscription|
          send('Subscribe', exchange: subscription.exchange, routing_key: subscription.routing_key)
        end
      end

      def successful_subscription(payload)
        key = subscription_key(payload['exchange'], payload['routing_key'])
        subscription = subscriptions[key]
        subscription&.subscribed!
      end

      def websocket_error(payload)
        raise Deploy::Errors::WebsocketError, payload['error']
      end

      def subscription_event(event, payload, rmq)
        key = subscription_key(rmq['e'], rmq['rk'])
        subscription = subscriptions[key]
        subscription&.dispatch(event, payload)
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
        uri = "#{Deploy.configuration.websocket_hostname}/pushwss"
        @connection ||= WebSocket::EventMachine::Client.connect(uri: uri)
      end

      def reset_connection
        @connection = nil
      end

      def logger
        @logger ||= Logger.new($stdout)
        @logger.level = Logger::ERROR
        @logger
      end

      def subscription_key(exchange, routing_key)
        [exchange, routing_key].join('-')
      end

    end

  end
end
