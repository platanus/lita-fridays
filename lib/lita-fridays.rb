require "lita"
require "redis"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/fridays"
require "lita/services/presentation_manager"

Lita::Handlers::Fridays.template_root File.expand_path(
  File.join("..", "..", "templates"),
  __FILE__
)
