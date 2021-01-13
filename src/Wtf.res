open Show

open Context
open Typechecker
open Types



// map over tyNode optionally replacing a node
let rec mapTy : (tyNode => option<tyNode>, tyNode) => tyNode
 = (f, n) => {
    let fieldMap = field => ({
        name: field.name,
        ty: mapTy(f, field.ty)
    })
    switch f(n) {
        | Some(t) => mapTy(f, t)
        | None => switch n {
                | Array({arr}) => mapTy(f, arr)
                | NamedProduct({nprod}) => NamedProduct({nprod:Belt.Array.map(nprod, fieldMap)})
                | AnonProduct({aprod}) => AnonProduct({aprod: Belt.Array.map(aprod, mapTy(f))})
                | NamedSum({nsum}) => NamedSum({nsum: Belt.Array.map(nsum, fieldMap)})
                | Ref({refTy}) => Ref({refTy: mapTy(f, refTy)})
                | _ => n
        }
    }
}

// resolve reference types
let resolveVar : (context, tyNode) => option<tyNode>
  = (ctx, ty) => switch ty {
    | Var({tyVar}) => lookupTy(ctx, tyVar)
    | _ => None
  }


let checker = ast => {
    let reducer = (ctx, decl) => switch decl {
        | TermDecl({name,tm,ty}) => {
            switch Js.Nullable.toOption(ty) {
                | Some(t) => {
                    let resolved = mapTy(resolveVar(ctx), t)
                    if Js.Option.isNone(checkType(ctx,tm,resolved)) {
                        Js.log("Error: failed to typecheck, skipping " ++ name)
                        ctx
                    } else {
                        Js.log4("Term", name, "added to context" , showTerm(tm))
                        extend(ctx, name, decl)
                    }
                }
                | None => {
                    Js.log("Error: un-annotated terms not yet supported, skipping " ++ name)
                    ctx
                }
            }
        }
        | TypeDecl({name, ty}) => {
            let ty' = mapTy(resolveVar(ctx), ty)
            Js.log4("Type", name, "added to context", showType(ty'))
            let d = TypeDecl({name, ty: ty'})
            extend(ctx, name, d)
        }
    }
    Js.Array.reduce(reducer, emptyContext, ast)
}

let check = s => switch TLDR.parse(s) {
    | Ok(ast) => Ok(checker(ast))
    | _ => Error("parse error")
}

let src1 = `
term k : (int * int * int) = (1 * 2 * 3)
type Q = {|A:int |B:bool}
term q : Q = (B|f)
term z:int = 123
term y2:int = z
type X = {*A:int *B:bool}
term x : X = {*A=123 *B=f}
term y : {
| A: int
| B: bool
} = (A| 123 )
term z : [bool] = {
    *a=t
    *b=1
    *c=3
}
`
let src = `
type Q = {
   * pair: (int * bool)
   * other: string
}
term q0 : Q = {
   * pair = (123 * f)
   * other = "hello"
}
term q1 : Q = {
   * pair = (234 * t)
   * other = "goodbye"
}
`

switch check(src) {
    | Ok(ctx) => Js.log2("ctx", showContext(ctx))
    | Error(e) => Js.log2("error", e)
}