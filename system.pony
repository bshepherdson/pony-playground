use "json"
use "time"

class System is FromJSON
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

  new from_json(obj: JsonObject) =>
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

