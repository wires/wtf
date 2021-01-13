# Manual

Lets give a somewhat complete example showing all the features

```

; term variables
term z:int = 123
term y:int = z

; anonymous products & inline types
term k : (int * int * int) = (1 * 2 * 3)

; sum types and type variables
type Q = {
    |A:int
    |B:bool
}
term qA : Q = (A|123)
term qB : Q = (B|f)

; named product type
type X = {
    *A:int
    *B:bool
}
term x : X = {*A=123 *B=f}


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

; reference terms
term q0Ref : &Q = #q0
term remoteQRef : &Q = #a9d311488dbe55eb3099.0.1.2
```

## Names

We must follow these two rules when naming things.

- Names for types **must** start with a `CapitalLetter`.
- Names for terms **must** start with a `lowerCaseLetter`.

## Base Types

Supported base types are `unit`, `bool`, `int`, `float`, `string` & `bytes`.

Terms are written as:

- bool `t` or `f`
- int `123`, float `0.123`
- string `"hi \"world\""`
- bytes `0xfeedc0de`

## Arrays

Write `[a]` for the type array of `a`'s. Terms are written as `[1 2 3]`.

## Named Product

Product types are written `{ *tag_0:Ty_0 ... *tag_n:Ty_ }`, for example
```
{
    * name : string
    * age : int
    * verified : bool
}
```

The terms are written similarly

```
{ *name="Alice" *age=99 *verified=t }
```

## Named Sum

Sum or co-product type is written as `{ |tag_0:Ty_0 ... |tag_n:Ty_n }`
```
{
    | okay: string
    | error: string
}
```

And a term of such a type looks like `(tag|..)`

```
(ok|"all good")
```

## Variables

You can refer to terms or types in the context using their name. To add a term or type to the context, write

```
type X = int
term x:X = 123
term y = y
```

## References

To define a reference to something of type `T` write `&T`. To give a term, you need to give a name to a term of that type.

```
type IntRef = &int
term fortyTwo : int = 42
term ref42 : IntRef = #fortyTwo
```

When a type can be inferred you can omit it.

- (TODO inference is not implemented yet)
- (TODO inference for sum types requires subtyping, which is not implemented yet)

```
term p : int = 42
term p' = 42
```

