module Vtasks
module Utils
# System module
module System
  # Check if command exists
  def command?(command)
    system("command -v #{command} >/dev/null 2>&1")
  end
end # module System
end # module Utils
end # module Vtasks
