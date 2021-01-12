open Show

let r : TLDR.parseResult = TLDR.tldrParser(`
type X = {|A:int |B:bool}
term x : X = (B|f)
term x' : &X = #x
term k = (1 * 2 * 3)
term z : [bool] = {
    *a=t
    *b=1
    *c=3
}
term f = #k
`)

showParseResult(r)