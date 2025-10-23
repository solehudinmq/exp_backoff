module ExpBackoff
  module Error
    class HttpError < StandardError
      attr_reader :status_code

      def initialize(message, status_code)
        super(message)
        @status_code = status_code
      end
    end
  end
end