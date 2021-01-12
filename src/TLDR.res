// wrappers for generated PEG.js parsers
// run `pnpm run build-tldr2-parser`
open Types

type jsParseResult = {
    "parse": option<tldrAST>,//Js.Json.t>,
    "syntaxError": option<syntaxError>
}

type parseResult = result<tldrAST, syntaxError>

let parsePEG : string => jsParseResult
    = %raw(`s => {
    const P = require("./parsers/tldr-parser.js")
    try {
        return {parse: P.parse(s)}
    }
    catch(e) {
        if(e instanceof P.SyntaxError) {
            let {message,found,expected,location,stack} = e
            let expFn = e => ({
                kind: e.type,
                message: e.message,
                location: e.location,
                found: e.found,
                stack: e.stack
            })
            let expected_ = expected.map(expFn)
            return {syntaxError: {message,found,expected:expected_,location,stack}}
        } else {
            throw e
        }
    }
}
`)

let handlResult : (jsParseResult, tldrAST => parseResult, syntaxError => parseResult) => parseResult
    = (x, parseFn, errFn) => {
    let parse = x["parse"]
    let syntaxError = x["syntaxError"]
    let isThere = Js.Option.isSome
    let getExn = Belt.Option.getExn
    if(isThere(syntaxError)) { 
        errFn(getExn(syntaxError))
    } else {
        parseFn(getExn(parse))
    }
}

let tldrParser : string => parseResult
    = s => {
        let x = parsePEG(s)
        let parseFn : tldrAST => parseResult = x => Ok(x)
        let errFn : syntaxError => parseResult = x => Error(x)
        handlResult(x, parseFn, errFn)
    }