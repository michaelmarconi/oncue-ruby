module OnCue

  class OnCueError < StandardError; end

  class InvalidConfigurationError < OnCueError; end

  class JobNotQueuedError < OnCueError; end

  class UnexpectedServerResponse < OnCueError; end

end