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
      (@🏺 ||= []).concat(procify(λ, *args))
    end

    def transdeal *objects, skip_global_callbacks: false, callback: nil, &λ
      ⚑ = nil
      ActiveRecord::Base.transaction do
        begin
          λ[]
        rescue => e
          ⚑ = {exception: e, data: objects}
          raise
        end
      end
    ensure
      if ⚑
        🏺!(⚑) unless skip_global_callbacks
        procify(callback).each { |λ| λ.(⚑) }
      end
    end
    alias_method :transaction, :transdeal

    protected

    def 🏺!(data)
      @🏺.each { |λ| λ.(data) } if @🏺.is_a?(Array)
    end

    private

    def procify(*args)
      (args.size == 1 && args.first.is_a?(Array) ? args.first : args).map do |backend|
        case backend
        when NilClass then nil
        when Hash then hash_to_proc(backend)
        when Symbol then hash_to_proc(receiver: backend)
        when ->(be) { be.respond_to?(:to_proc) } then backend.to_proc
        else hash_to_proc(receiver: backend)
        end
      end.compact
    end

    def hash_to_proc receiver:, method: nil
      receiver =
        case receiver
        when String, Symbol then Kernel.const_get(receiver.to_s.camelize)
        else receiver
        end

      method =
        [method, *%i|store run perform_async perform call []|].compact.detect do |m|
          receiver.respond_to?(m)
        end

      method.nil? ?
        raise(InvalidBackend.new(any)) : receiver.method(method).to_proc
    end
  end
end
