open Types

module StringCmp = Belt.Id.MakeComparable({
  type t = string
  let cmp = compare
});

type context = Belt.Map.t<string,decl,StringCmp.identity>

let emptyContext : context = Belt.Map.make(~id=module(StringCmp))

let lookup = (ctx:context, x:string) : option<decl> => Belt.Map.get(ctx, x)

// TODO can speedup, capital names are types, lower case names are terms
// use two contexts?
let lookupTy = (ctx, key) => switch lookup(ctx,key) {
  | Some(decl) => switch decl {
    | TypeDecl({ty}) => Some(ty)
    | _ => None
  }
  | None => None
}

let extend = (ctx:context, l:string, t:decl) : context => Belt.Map.set(ctx, l, t)