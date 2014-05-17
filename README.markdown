# typedclojure.vim

<a href='http://typedclojure.org'><img src='images/part-of-typed-clojure-project.png'></a>

The official Typed Clojure vim plugin.

## Installation

typedclojure.vim requires [fireplace.vim](https://github.com/tpope/vim-fireplace).

If you're using [pathogen.vim](https://github.com/tpope/vim-pathogen), install typedclojure.vim
with these commands:

```
cd ~/.vim/bundle
git clone git://github.com/typedclojure/vim-typedclojure.git
```

If you're using [Vundle.vim](https://github.com/gmarik/Vundle.vim), install typedclojure.vim
by adding this line to your vimrc, and then run `Bundle`.

```
Bundle 'typedclojure/vim-typedclojure'
```

After generating the helptags, view the manual with `:help typedclojure`.

## Features

See `:help typedclojure` for this information.

### Type checking namespaces

To type check the current namespace, call `:CheckNs` or input `ctn` 
(think 'core.typed check namespace').

Any type errors are loaded into a quickfix list, which can be navigated like fireplace's
quickfix window for stack traces.

<img src='images/preview-window.png'>

Hovering over an entry in the quickfix window and inputting `ce` will open a preview window
with a nicely formatted copy of the type error message on the current line.

### Local type information

After type checking a file, use `:TypeAt` or `cK` to query the type at a
position in the type checked file. In GUI mode, mouse hovering has the same effect,
but with balloon popups.

<img src='images/typed-clojure-mouseover.png'>

Aim your mouse/cursor at the leftmost character in a form.

## License

Copyright (c) Ambrose Bonnaire-Sergeant.  Distributed under the same terms as Vim itself.
See `:help license`.

