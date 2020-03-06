# Juno 1.0 Project

TODO: We may want to migrate this into our future (unified) repository.

## Plans

### Unify `julia-client` and `ink`

Basically we want to migrate `ink` into `julia-client`.
Instead of just moving code in the former into the latter,
I would rather create a brand new repository, let's say `JunoLab/Juno`, and put the work into there.

This should give us several _huge_ improvements:
- **Easy installation/update**: An user just need to install/update only one package
- **Better startup time**: A loading/activation consumed on deserialization should vastly improve; we can statically serialize/deserialize items without inter-package interactions
  * We may be able to go even future, by deserializing items lazily or something like that
- Better maintainability
  * E.g.: CI won't break because of incompatibility between julia-client and ink (although we still don't have enough test suites for code in Atom side :P)
  * And also, we can think of `JunoLab/Juno` as a new main repository of our project, i.e. issues/FRs will be bundled there, documentation can be developed there and so on

This will require **tons** of work; we need man power !

NOTE:
In theory, the UI components in `ink` are better to be composable,
and this is why they have been developed separately so far AFAIU.
But Atom is no longer a popular place to develop an IDE and now
we want to focus on our benefits rather than the ideal form of software for general uses.

### Ship Julia packages in the unified Atom package

Bundles Julia packages that constitute Juno within `JunoLab/Juno`, as [julia-vscode extension](https://github.com/julia-vscode/julia-vscode) does to some extent.

This also brings several and similar user experience improvements:
- **Easy installation/update**: Users now don't need to update both Atom and Julia packages separately; what they need to do is only to update `JunoLab/Juno`, the new unified Atom package
- **Non-interference with user's environment**
  * By hacking on uuids of our Juno-related packages (Julia side), we can trick Julia into seeing them as totally different packages from user's ones, even when they are actually the same or ones with different versions
  * This means Juno users no longer worry about incompatibility between Juno packages and the ones they want to use for their use

### Moar IDE features

We already started to provide (ordinary) IDE features based on static code analysis using [CSTParser](https://github.com/julia-vscode/CSTParser.jl), like outline/goto, but we can go even more further.

Judging from what users require/complain about (and of course from our own interests), these features seem to have high priority:
- linter implementation: @pfitzseb actually already implemented the linter on UI side, but we still not have its backend implementation on Julia side
- rename refactor: [WIP here](https://github.com/JunoLab/Atom.jl/pull/203)
- symbols view: can be nicely integrated with rename refactor feature
- outline view: can be enhanced more by allowing nested items
  * once it becomes to handle nested items, our outline view can be used for more things, like markdown, TOML, Weave document, etc

For implementing these features, I would like to go with our own implementations, i.e. don't just rely on [StaticLint.jl](https://github.com/julia-vscode/StaticLint.jl), because:
- caching everything on the first time environment loading isn't preferable from our point of view
- its linter implementation is sometimes too conservative; maybe it's because it doesn't use runtime information, which can be very helpful for linting, while it's a core functionality of Juno

These features are kinda related to each other.
First I would like to refactor [our global (goto) symbol cache](https://github.com/JunoLab/Atom.jl/blob/e8abd9b8e19e7100471dd110a4d417817a53d4e2/src/goto.jl#L146-L164) and make it suitable for more general uses, and then we can reuse it for all the things.
By using user runtime information, it may be possible to enhance their implementations even more.

## Ideas

There are several other things we've wanted to do.
List them here because they have less priority than things above in terms of releasing Juno 1.0.

- update documentation and showcase our latest features: there are lots of features that only we developers know !
  * https://github.com/JunoLab/Juno.jl/issues/419
- improve module handling:
  * https://github.com/JunoLab/Juno.jl/issues/411
  * https://github.com/timholy/Revise.jl/issues/391
  * https://github.com/JunoLab/Juno.jl/issues/407
- [Infiltrator.jl](https://github.com/JuliaDebug/Infiltrator.jl) integration
- [Literate.jl](https://github.com/fredrikekre/Literate.jl) integration
- improvements on remote sessions
