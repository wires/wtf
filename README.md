# Well Typed Foundations 🏛️

> NB: I realize `wtf` is immature possibly offensive to people. At the same
> time I am absolutely offended by the state of the world, how people are
> treating our planet and all the living sentient beings on it, how we are
> polluting everything and destroying the future for everyone.
> Et-f**king-ceteral. Where is the outrage about that?
>
> I will rename this eventually, but for now please pretend `wtf` really means
> "well typed foundations" because that is really what this is.
>
> Thank you

Like JSON but better.

Create a file `stuff.wtf`:

```
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
```

In this file we defined three top level elements, a type `Q` and two typed terms `q0`, `q1`. Let's check the file for correctness (this actually proofs that `q0` and `q1` are of the shape `Q`).

```
$ wtf check stuff.wtf
Type Q ✔
term q0:Q ✔
term q1:Q ✔
```

See [docs/syntax.md](docs/syntax.md) for more information.

## Development

```sh
pnpm run build-tldr-parser # peg parsers
pnpm run build # rescript build once
pnpm run watch # rescript build with watching
pnpm run start # run once, node src/Wtf.bs.js
pnpm run runwatch # run with watching, nodemon src/Wtf.bs.js
```

### TODO

- [ ] implement type inference
- [ ] generate `terms.res` `types.res`
- [ ] generate `codec.res` and `.brb` serialization
