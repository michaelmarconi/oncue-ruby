module OnCue
  class Job
    attr_accessor :id, :worker_type, :enqueued_at

    def initialize(id, worker_type, enqueued_at)
        @id = id
        @worker_type = worker_type
        @enqueued_at = enqueued_at
    end
  end
end