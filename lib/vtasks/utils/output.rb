module Vtasks
module Utils
# Output module
module Output
  # Colorize output
  module Colorize
    def colorize(color_code)
      "\e[#{color_code}m#{self}\e[0m"
    end

    def red
      colorize(31)
    end

    def green
      colorize(32)
    end

    def blue
      colorize(34)
    end

    def yellow
      colorize(33)
    end

    def white
      colorize(37)
    end

    def bold
      colorize(1)
    end

    def italic
      colorize(3)
    end

    def underline
      colorize(4)
    end
  end

  # Add colorize to the String class
  String.include Colorize

  # Debug message
  def debug(message)
    puts "==> #{message}".green if $DEBUG
  end

  # Information message
  def info(message)
    puts "==> #{message}".green
  end

  # Warning message
  def warn(message)
    puts "==> #{message}".yellow
  end

  # Error message
  def error(message)
    puts "==> #{message}".red
  end
end # module Output
end # module Utils
end # module Vtasks
