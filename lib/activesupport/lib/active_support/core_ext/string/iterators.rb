# Gregor
# - require 'strscan'

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      # Custom string iterators
      module Iterators
        # Yields a single-character string for each character in the string.
        # When $KCODE = 'UTF8', multi-byte characters are yielded appropriately.
        def each_char
# Gregor
# +
          self.each_byte do | byte |
            yield( byte.chr )
          end
# -          scanner, char = StringScanner.new(self), /./mu
# -          loop { yield(scanner.scan(char) || break) }
        end
      end
    end
  end
end
