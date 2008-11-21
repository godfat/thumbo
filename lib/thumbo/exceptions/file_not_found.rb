
module Thumbo
  class FileNotFound < StandardError
    def initialize filename
      super("Thumbo: File `#{filename}' was not found.")
    end
  end
end
