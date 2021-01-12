open Context
open Types
open Show

// TODO introduce sum for base types (ilke tmBase)
let baseStr : tmBase => string = b => switch b {
  | TmUnit => "unit"
  | TmBool(_) => "bool"
  | TmInt(_) => "int"
  | TmFloat(_) => "float"
  | TmString(_) => "string"
  | TmBytes(_) => "bytes"
}

let typeForBaseTerm : tmBase => tyNode = b => Base({base: b|>baseStr})

let forgetTmNames : array<tmField> => array<tmNode>
  = fs => Js.Array.map(f => f.tm, fs)

let forgetTyNames : array<tyField> => array<tyNode>
  = fs => Js.Array.map(f => f.ty, fs)


// check tm_0:ty .. tm_n:ty
let rec checkAllSame
  : (context, array<tmNode>, tyNode) => bool
  = (ctx, terms, ty) => Js.Array.reduce(
    (acc, tm) => {
      Js.log3("CheckAll", showTerm(tm), showType(ty))
      if (!acc) { false } else { Js.Option.isSome(checkType(ctx, tm, ty)) }
    }, true, terms)
and
// check tm_0:ty_0 .. tm_n:ty_n
checkAll
  : (context, array<tmNode>, array<tyNode>) => bool
  = (ctx, terms, types) => {
    if (Js.Array.length(terms) !== Js.Array.length(types)) {
      false
    } else {
      let tmty = Belt.Array.zip(terms, types)
      let reducer = (acc, (tm, ty)) => {
        if(!acc) { false } else {
          Js.Option.isSome(checkType(ctx, tm, ty))
        }
      }
      Js.Array.reduce(reducer, true, tmty)
    }
  }
and checkFields : (context, array<tmField>, array<tyField>) => bool
  = (ctx, tmFields, tyFields) => {
    let check = (tm,ty) => Js.Option.isSome(checkType(ctx, tm, ty))
     if (Js.Array.length(tmFields) !== Js.Array.length(tyFields)) {
      false
    } else {
      let tmty = Belt.Array.zip(tmFields, tyFields)
      let reducer = (acc, (tmf, tyf)) => if !acc { false } else {
        tmf.n == tyf.name && check(tmf.tm, tyf.ty)
      }
      Js.Array.reduce(reducer, true, tmty)
    }
  }
and checkSum : (context, string, tmNode, array<tyField>) => bool
  = (ctx, tag, tm, nsum) => {
    let tyField = Js.Array.find(f => f.name == tag, nsum)
    let checkTy = f => Js.Option.isSome(checkType(ctx, tm, f.ty))
    Belt.Option.mapWithDefault(tyField, false, checkTy)
  }
and checkType : (context, tmNode, tyNode) => option<tyNode>
  = (ctx, term, ty) => {
    let resultWhen = (condition) => condition ? Some(ty) : None
    switch(term) {
      | TmBase({base}) => resultWhen(ty == typeForBaseTerm(base))
      | TmArray({arrayTerms}) => switch ty {
        | Array({arr}) => resultWhen(checkAllSame(ctx, arrayTerms, arr))
        | _ => None
      }
      | TmAnonProduct({product}) => switch ty {
        | AnonProduct({aprod}) => resultWhen(checkAll(ctx, product, aprod))
        | _ => None
      }
      | TmNamedProduct({fields}) => switch ty {
        | NamedProduct({nprod}) => resultWhen(checkFields(ctx, fields, nprod))
        | _ => None
      }
      | TmNamedSum({tag,tm}) => switch ty {
        | NamedSum({nsum}) => resultWhen(checkSum(ctx, tag, tm, nsum))
        | _ => None
      }
      | TmRef({ref}) => switch ty {
        | Ref({refTy}) => {
          // TODO
          // - look for term in context `r = lookup(ctx, ref)`
          // - check type of term `checkType(ctx, r, refTy)`
          Js.log("TODO need to implement ref")
          None
        }
        | _ => None
      }
      | TmVar({var}) => {
        let declOption = lookup(ctx, var)
        let fn = decl => {
          switch decl {
            | TermDecl({tm}) => resultWhen(Js.Option.isSome(checkType(ctx, tm, ty)))
            | _ => None
          }
        }
        Belt.Option.mapWithDefault(declOption, None, fn)
      }
      | _ => switch inferTy(ctx, term) {
          | Some(t2) => if (ty == t2) { Some(ty) } else { None }
          | _ => None
      }
    }
  }

and inferTy : (context, tmNode) => option<tyNode>
 // TODO implement inference
 = (ctx,tm) => Some(Base({base:"unit"}))
