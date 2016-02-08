use "json"

class Commodity is FromJSON
  let id: I64
  let name: String
  let category_id: I64
  let is_rare: Bool

  new from_json(obj: JsonObject) =>
    id = try obj.data("id") as I64 else 0 end
    name = try obj.data("name") as String else "BAD PARSE" end
    category_id = try obj.data("category_id") as I64 else 0 end
    is_rare = try obj.data("is_rare") as Bool else false end
