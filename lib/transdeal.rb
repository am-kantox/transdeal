require 'transdeal/version'

module Transdeal
  class InvalidBackend < RuntimeError
    def initialize(object)
      super "Invalid backend [#{object.inspect}].\n" \
            "Expected {class: ..., method: ...} Hash or " \
            "class name / class responding to :store, :run or :perform."
    end
  end

  class << self
    def configure *args, &λ
      (@🏺 ||= []).push \
        *args.map do |backend|
          case backend
          when Hash then hash_to_proc(backend)
          when Symbol then hash_to_proc(receiver: backend)
          when ->(any) { any.respond_to(:to_proc) } then any.to_proc
          else hash_to_proc(receiver: backend)
          end
        end.tap { |🏺| 🏺 << λ if λ }
    end

    def transdeal *objects, &λ
      ⚑ = nil
      ActiveRecord::Base.transaction do
        begin
          λ[]
        rescue
          ⚑ = objects
          raise
        end
      end
    ensure
      🏺!(⚑) if ⚑
    end

    protected

    def 🏺!(data)
      @🏺.each { |λ| λ.(data) } if @🏺.is_a?(Array)
    end

    private

    def hash_to_proc any
      receiver =
        case any[:receiver]
        when String, Symbol then Kernel.const_get(any[:receiver].to_s.camelize)
        else any[:receiver]
        end

      method =
        [any[:method], *%i|store run perform_async perform call []|].detect do |m|
          receiver.respond_to?(m)
        end

      method.nil? ?
        raise(InvalidBackend.new(any)) : receiver.method(method)
    end
  end
end
