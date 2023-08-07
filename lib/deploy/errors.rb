module Deploy

  ## Base level error which all other deploy errors will inherit from. It may also be
  ## invoked for errors which don't directly relate to other errors below.
  class Error < StandardError; end

  module Errors

    ## The service is currently unavailable. This may be caused by rate limiting or the API
    ## or the service has been disabled by the system
    class ServiceUnavailable < Error; end

    ## Access was denied to the remote service
    class AccessDenied < Error; end

    ## A communication error occurred while talking to the Deploy API
    class CommunicationError < Error; end

    # A timeout error
    class TimeoutError < Error; end

    # Raised from the websocket client when we receive an error event
    class WebsocketError < Error; end
  end
end
