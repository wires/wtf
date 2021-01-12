
// Parser Errors
type expected_ = {kind:string, parts: array<string>, inverted:bool, ignoreCase:bool}
type expected = array<expected_>
type position = { offset: int, line: int, column: int}
type location = { start: position, end: position}
type syntaxError = {
    message: string,
    found: string,
    expected: expected,
    location: location,
    stack: string
}

// field
type rec tyField = {
    name: string,
    ty: tyNode
}

// type
and tyNode =
| Base({base:string})
| Array({arr:tyNode})
| NamedProduct({nprod:array<tyField>})
| AnonProduct({aprod: array<tyNode>})
| NamedSum({nsum:array<tyField>})
| Ref({refTy:tyNode})
| Var({tyVar:string})

// baseTerm
and tmBase =
| TmUnit
| TmBool({boolVal:bool})
| TmInt({intVal:int})
| TmFloat({floatVal:float})
| TmString({stringVal:string})
| TmBytes({bytesVal:string})

// baseField
and tmField = { n:string, tm:tmNode }

// term
and tmNode =
| TmBase({base:tmBase})
| TmArray({arrayTerms:array<tmNode>})
| TmNamedProduct({fields:array<tmField>})
| TmAnonProduct({product:array<tmNode>})
| TmNamedSum({tag:string,tm:tmNode})
| TmVar({var:string})
| TmRef({ref:string})

// declaration
and decl =
| TypeDecl({name:string, ty:tyNode})
| TermDecl({name:string, tm:tmNode, ty:Js.Nullable.t<tyNode>})

and tldrAST = array<decl>


let rec mapTy : (tyNode => option<tyNode>, tyNode) => tyNode
 = (f, n) => switch f(n) {
 | Some(t) => mapTy(f, t)
 | None => switch n {
        | Array({arr}) => mapTy(f, arr)
        | NamedProduct({nprod}) => {
            let fieldMap = field => ({
                name: field.name,
                ty: mapTy(f, field.ty)
            })
            let newFields = Belt.Array.map(nprod, fieldMap)
            NamedProduct({nprod:newFields})
        }
        | _ => n
    }
 }