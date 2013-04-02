require 'date'

module OnCue

  class Job

    attr_reader :id, :enqueued_at

    def initialize(id, enqueued_at)
      @id = id
      @enqueued_at = DateTime.iso8601(enqueued_at)
    end

    def self.json_create(o)
      new(o['id'], o['enqueuedAt'])
    end

    def ==(other)
      other.equal?(self) || (other.instance_of?(self.class) && other.id == @id && other.enqueued_at == @enqueued_at)
    end

  end

end