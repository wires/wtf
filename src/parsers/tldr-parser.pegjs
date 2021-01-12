Decls = _ l:Decl ls:(_ d:Decl { return d })* _ { return [l].concat(ls).flat() }
 / _ { return [] }

Decl = TyDecl / TmDecl

TyDecl = "type" _ name:typeName _ "=" _ ty:Ty {
  return {TAG: 0, name, ty}
}

TmDecl = "term" _ name:termName ty:(_":"_ T:Ty { return T })? _ "=" _ tm:Tm {
 return {TAG:1 , name, ty, tm}
}

TmBase
 = "()"   { return 0 }
 / "t"    { return {TAG:0, boolVal: true} }
 / "f"    { return {TAG:0, boolVal: false} }
 / TmString
 / TmBytes
 / [0-9]+ "." [0-9]* { return {TAG:2, floatVal: parseFloat(text()) } }
 / [0-9]+  { return {TAG:1, intVal: parseInt(text())} }
 
TmChar
  // escaped "
  = &('\\"') '\\"' { return '"' }
  // anything but "
/ !('\\"') [^"]

TmString = '"' TmChar* '"' {
  let x = text()
  let stringVal = x.slice(1, x.length - 1)
  return { TAG: 3, stringVal }
}

TmByte = ([a-f0-9][a-f0-9])
TmBytes = '0x' TmByte* {
  let bytesVal = text().slice(2)
  return { TAG: 4, bytesVal }
}

// composite terms
TmArrEls = tm:Tm tms:(_ t:Tm {return t})* { return [tm].concat(tms) }
TmArray = "[" _ arrayTerms:TmArrEls _ "]" {
  return { TAG: 1, arrayTerms }
}

// named product terms

namedTerm = n:id _ "=" _ tm:Tm { return { n, tm } }
namedProductElems = (_ "*" _ nt:namedTerm { return nt })+

// anonymous product terms
anonProductElems = t:Tm ts:(_ "*" _ tm:Tm { return tm } )* { return [t].concat(ts) }

// products
TmProduct
	= &("{" _ "*") "{" _ fields:namedProductElems _ "}" {
        return { TAG: 2, fields }
    }
    / "(" _ product:anonProductElems _ ")" {
        return { TAG: 3, product }
    }

// coproduct
TmCoproduct
  // named
  = "(" _ tag:tag _ "|" _ tm:Tm _ ")" {
    return { TAG: 4, tag, tm }
  }

TmVar = termName { return { TAG: 5, var: text() } }

TmRef = "#" termName { return { TAG: 6, ref: text().slice(1) } }

Tm
 = base:TmBase { return {TAG:0, base} }
 / TmArray
 / TmProduct
 / TmCoproduct
 / TmVar
 / TmRef

Ty = Base / Array / Product / Sum / Ref / Var

Var = typeName { return { TAG:6, tyVar: text() } }

Ref
  = "&" refTy:Ty { return { TAG:5, refTy } }

Sum
  = &("{" _ "|" ) "{" _ nsum:namesSum _ "}" {
    return {TAG:4, nsum}
  }

Product
  = &("{" _ "*" ) "{" nprod:namesProd _ "}" {
    return {TAG:2, nprod}
  }
  / !("(" _ "*" ) "(" _ aprod:anonProd _ ")" {
	// empty product is the unit type
	if(aprod.length == 0) { return {TAG:0, base: 'unit'} }
    // singleton product doesn't exist, it's just brackets
    if(aprod.length == 1) { return aprod[0] }
    return {TAG:3, aprod}
  }

namesProd = (_ "*" _ name:name _ ":" _ ty:Ty { return {name,ty} } )+
namesSum  = (_ "|" _ name:name _ ":" _ ty:Ty { return {name,ty} } )+
anonProd
	= t:Ty ts:(_ "*" _ ty:Ty { return ty })* { return [t].concat(ts) }
	/ _ { return [] }

Array = "[" arr:Ty "]" {
  return {TAG:1, arr}
}

BaseSort = "unit" / "bool" / "int" / "float" / "string" / "bytes"
Base = base:BaseSort {
  return {TAG:0, base}
}

anyWordChar = [a-zA-Z0-9'_]
name = $(anyWordChar+)
typeName = $([A-Z]anyWordChar*)
termName = $([a-z]anyWordChar*)
id = $([a-zA-Z]anyWordChar*)
tag = $([0-9a-zA-Z]anyWordChar*)
_ = [ \n\r]*