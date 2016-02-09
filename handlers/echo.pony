use ".."
use "json"
use "net"

actor EchoHandler is Handler
  let _env: Env
  let _universe: Universe

  new create(env: Env, uni: Universe) =>
    _env = env
    _universe = uni

  be handle(conn: TCPConnection tag, req: JsonObject val) =>
    conn.write("server says: ")
    conn.write(req.string())

