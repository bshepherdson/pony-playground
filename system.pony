use "collections"
use "json"
use "time"

class System is (FromJSON & ToJSON)
  let id: U32
  let name: String
  let x: F64
  let y: F64
  let z: F64

  let faction: String
  let government: String
  let allegiance: String

  let power: String
  let power_state: String
  let needs_permit: Bool

  let updated_at: Date

  new val from_json(obj: JsonObject val) =>
    id = try (obj.data("id") as I64).u32() else 0 end
    name = try obj.data("name") as String else "BAD PARSE" end

    x = try obj.data("x") as F64 else 0 end
    y = try obj.data("y") as F64 else 0 end
    z = try obj.data("z") as F64 else 0 end

    faction = try obj.data("faction") as String else "BAD PARSE" end
    government = try obj.data("government") as String else "BAD PARSE" end
    allegiance = try obj.data("allegiance") as String else "BAD PARSE" end

    power = try obj.data("power") as String else "BAD PARSE" end
    power_state = try obj.data("power_state") as String else "BAD PARSE" end
    needs_permit = try obj.data("needs_permit") as Bool else false end

    updated_at = Date(try obj.data("updated_at") as I64 else 0 end)

  fun as_map() : Map[String, JsonType] =>
    var map = Map[String, JsonType]()
    map("id") = id.i64()
    map("name") = name
    map("x") = x
    map("y") = y
    map("z") = z

    map("faction") = faction
    map("government") = government
    map("allegiance") = allegiance

    map("power") = power
    map("power_state") = power_state
    map("needs_permit") = needs_permit

    map("updated_at") = updated_at.time()
    map

