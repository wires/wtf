
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
type rec tldrTyField = {
    name: string,
    ty: tldrTyNode
}

// type
and tldrTyNode =
| Base({base:string})
| Array({arr:tldrTyNode})
| NamedProduct({nprod:array<tldrTyField>})
| AnonProduct({aprod: array<tldrTyNode>})
| NamedSum({nsum:array<tldrTyField>})
| Ref({refTy:tldrTyNode})
| Var({tyVar:string})

// baseTerm
and tldrTmBase =
| TmUnit
| TmBool({boolVal:bool})
| TmInt({intVal:int})
| TmFloat({floatVal:float})
| TmString({stringVal:string})
| TmBytes({bytesVal:string})

// baseField
and tldrTmField = { n:string, tm:tldrTmN }

// term
and tldrTmN =
| TmBase({base:tldrTmBase})
| TmArray({arrayTerms:array<tldrTmN>})
| TmNamedProduct({fields:array<tldrTmField>})
| TmAnonProduct({product:array<tldrTmN>})
| TmNamedSum({tag:string,tm:tldrTmN})
| TmVar({var:string})
| TmRef({ref:string})

// declaration
and tldrDecl =
| TypeDecl({name:string, ty:tldrTyNode})
| TermDecl({name:string, tm:tldrTmN, ty:Js.Nullable.t<tldrTyNode>})
and tldrAST = array<tldrDecl>