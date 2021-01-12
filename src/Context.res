module StringMap = Map.Make({
  type t = string;
  let compare = compare
});

type ty = Types.tldrDecl

type context = StringMap.t<ty>

let emptyContext : context = StringMap.empty

let lookup = (ctx:context, x:string) : option<ty> => try {
    Some(StringMap.find(x, ctx))
} catch {
    | _ => None
}

let extend = (ctx:context, l:string, t:ty) : context => StringMap.add(l, t, ctx);
