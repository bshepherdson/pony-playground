class _KDNode[K: Comparable[K] val, V: Any val]
  let depth : USize
  let point : Array[K] val
  let key : K
  let value : V
  var left : (_KDNode[K, V] | None) = None
  var right : (_KDNode[K, V] | None) = None

  new create(p : Array[K] val, d : USize val, v : V) ? =>
    depth = d
    point = p
    key = p(d % p.size())
    value = v

class KDTree[K: Comparable[K] val, V: Any val]
  let dimensions : USize
  var _root : (_KDNode[K, V] | None) = None

  new create(dim : USize) =>
    dimensions = dim

  fun ref update(k : Array[K] val, value : V) ? =>
    """Inserts the given value into the tree. Overwrites if it already
    exists."""
    match _root
    | None => _root = _KDNode[K, V].create(k, 0, value)
    | let r : _KDNode[K, V] => _insert(r, 0, k, value)
    end

  fun ref _insert(n : _KDNode[K, V], depth : USize, k : Array[K] val,
      value : V) ? =>
    """Recursive insertion function that actually puts the value where it
    belongs. The tree is "accidentally balanced", meaning that values are
    inserted dumbly in the order they arrive. With randomly ordered input, that
    produces good results."""
    let p  = k(depth % k.size())
    match if p < n.key then n.left else n.right end
    | None =>
      let nu = _KDNode[K,V](k, depth + 1, value)
      if p < n.key then
        n.left  = nu
      else
        n.right = nu
      end
    | let sub : _KDNode[K,V] => _insert(sub, depth + 1, k, value)
    end

  fun selectRange(bounds : Array[(K, K)] val) : Array[V] iso^ ? =>
    """Takes an array of [(minX, maxX), (minY, maxY), ...] pairs, and returns an
    array of all values (V) in that rectangular prism. The ranges are treated as
    closed intervals."""
    var out = recover iso Array[V]() end
    _selectRange(_root, 0, bounds, consume out)

  fun _selectRange(node : (_KDNode[K, V] box | None), depth : USize,
      bounds : Array[(K, K)] val, out : Array[V] iso) : Array[V] iso^ ? =>
    match node
    | let n : _KDNode[K, V] box =>
      let b = bounds(depth % bounds.size())
      if n.key < b._1 then
        _selectRange(n.right, depth + 1, bounds, consume out)
      elseif n.key > b._2 then
        _selectRange(n.left, depth + 1, bounds, consume out)
      else
        // First, check if this node is inside each dimension of the bounds.
        var contained = true
        for (i,bd) in bounds.pairs() do
          let p = n.point(i)
          if (p < bd._1) or (bd._2 < p) then
            contained = false
            break
          end
        end

        if contained then
          out.push(n.value)
        end

        var out' = _selectRange(n.left,  depth + 1, bounds, consume out)
        _selectRange(n.right, depth + 1, bounds, consume out')
      end
    else
      consume out
    end

