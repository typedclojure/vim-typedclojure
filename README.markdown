# typedclojure.vim

<a href='http://typedclojure.org'><img src='images/part-of-typed-clojure-project.png'></a>

This is official Typed Clojure vim plugin.

## Installation

Typed-Clojure.vim requires [fireplace.vim](https://github.com/tpope/vim-fireplace).

If you're using [pathogen.vim](https://github.com/tpope/vim-pathogen), install typed-clojure.vim
with these commands:

```
cd ~/.vim/bundle
git clone git://github.com/typedclojure/vim-typed-clojure.git
```

If you're using [Vundle.vim](https://github.com/gmarik/Vundle.vim), install typed-clojure.vim
by adding this line to your vimrc, and then run `Bundle`.

```
Bundle 'typedclojure/vim-typed-clojure'
```

After generating the helptags, view the manual with `help typed-clojure`.

## Features

See `:help typedclojure` for this information.

### Type checking namespaces

To type check the current namespace, call `:CheckNs` or input `ctn` 
(think 'core.typed check namespace').

Any type errors are loaded into a quickfix list, which can be navigated like fireplace's
quickfix window for stack traces.

Hovering over an entry in the quickfix window and inputting `ce` will open a preview window
with a nicely formatted copy of the type error message on the current line.

## License

Copyright (c) Ambrose Bonnaire-Sergeant.  Distributed under the same terms as Vim itself.
See `:help license`.

