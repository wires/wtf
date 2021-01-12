open Types

let showPosition : position => string = pos => {
    string_of_int(pos.line) ++ ":" ++ string_of_int(pos.column)
}

let showLocation : location => string = loc => {
    showPosition(loc.start) ++ "-" ++ showPosition(loc.end)
}

let showErr : syntaxError => string = err => {
    "[" ++ showLocation(err.location) ++ "] " ++ err.message
}

let mapjoin : (string, 'a => string, array<'a>) => string
 = (joinWith, f, xs) => Js.Array.joinWith(joinWith, Js.Array.map(f,xs))

let rec showNProd : tyField => string = f => "*" ++ f.name ++ ":" ++ showType(f.ty)
and showNSum : tyField => string = f => "|" ++ f.name ++ ":" ++ showType(f.ty)
and showNProds = xs => mapjoin(" ", showNProd, xs)
and showAProds = xs => mapjoin(" * ", showType, xs)
and showNSums = xs => mapjoin(" ", showNSum, xs)
and showType : tyNode => string
  = n => {
      switch n {
      | Base({base}) => base
      | Array({arr}) => "[" ++ showType(arr) ++ "]"
      | NamedProduct({nprod}) => "{" ++ showNProds(nprod) ++ "}"
      | AnonProduct({aprod}) => "(" ++ showAProds(aprod) ++ ")"
      | NamedSum({nsum}) => "(" ++ showNSums(nsum) ++ ")"
      | Ref({refTy}) => "&" ++ showType(refTy)
      | Var({tyVar}) => tyVar
      }
  }

let showBaseTerm : tmBase => string = b => {
    switch b {
    | TmUnit => "()"
    | TmBool({boolVal}) => string_of_bool(boolVal)
    | TmInt({intVal}) => string_of_int(intVal)
    | TmFloat({floatVal}) => (%raw(`s => s.toString()`)(floatVal))
    | TmString({stringVal}) => "\"" ++ stringVal ++ "\""
    | TmBytes({bytesVal}) => "0x" ++ bytesVal
    }
}
let rec showField : tmField => string = f => f.n ++ "=" ++ showTerm(f.tm)
and showTerm : tmNode => string = n => switch n {
| TmBase({base}) => showBaseTerm(base)
| TmArray({arrayTerms}) => "[" ++ mapjoin(" ", showTerm, arrayTerms) ++ "]"
| TmNamedProduct({fields}) => "{" ++ mapjoin(" ", showField, fields) ++ "}"
| TmAnonProduct({product}) => "(" ++ mapjoin(" * ", showTerm, product) ++ ")"
| TmNamedSum({tag,tm}) => "(" ++ tag ++ "|" ++ showTerm(tm) ++ ")"
| TmVar({var}) => var
| TmRef({ref}) => "#" ++ ref
}

let showDecl : decl => string
  = decl => switch decl {
    | TypeDecl({name, ty}) => "TypeDecl " ++ name ++ " = " ++ showType(ty)
    | TermDecl({name, tm, ty}) => {
        switch Js.Nullable.toOption(ty) {
        | Some(t) => "TermDecl " ++ name ++ " : " ++ showType(t) ++ " = " ++ showTerm(tm)
        | None => "TermDecl " ++ name ++ " = " ++ showTerm(tm)
        }
    }
  }
let showAST : tldrAST => string
    = ast => Js.Array.joinWith("\n", Js.Array.map(showDecl, ast))

let showParseResult = r => switch r {
| Ok(r) => Js.log(showAST(r))
| Error(e) => Js.log(showErr(e))
}

open Context
let showContext : context => string
    = ctx => {
        let f = ((n:string,d:decl)) => n ++ " -> " ++ showDecl(d)
        let cs = Belt.Array.map(Belt.Map.toArray(ctx), f)
        "\n  " ++ Js.Array.joinWith("\n  ", cs)
    }