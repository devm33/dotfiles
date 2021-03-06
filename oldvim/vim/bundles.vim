if &compatible
  set nocompatible
end

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Let Vundle manage Vundle
Bundle "gmarik/vundle"

" General
Bundle "ctrlpvim/ctrlp.vim"
Bundle "editorconfig/editorconfig-vim"
Bundle "flazz/vim-colorschemes"
Bundle "jeffkreeftmeijer/vim-numbertoggle"
Bundle "rking/ag.vim"
Bundle "scrooloose/nerdtree"
Bundle "scrooloose/syntastic"
" Bundle "skwp/greplace.vim"
" Bundle "tomtom/tcomment_vim"
" Bundle "tpope/vim-abolish"
" Bundle "tpope/vim-fugitive"
" Bundle "tpope/vim-repeat"
Bundle "tpope/vim-surround"
" Bundle "tpope/vim-unimpaired"
" Snippets
Bundle "sirver/ultisnips"

" Javascript
" Bundle "pangloss/vim-javascript"
" Bundle "jelera/vim-javascript-syntax"
" Bundle "othree/javascript-libraries-syntax.vim"
" Bundle "prettier/vim-prettier"
" Dart
" Bundle "dart-lang/dart-vim-plugin"
" Bundle "natebosch/dartlang-snippets"
" React JSX
" Bundle "mxw/vim-jsx"
" Plugin 'styled-components/vim-styled-components'
" Typescript
" Plugin 'Shougo/vimproc.vim'          " Force install a dependency of tsuquyomi.
" Plugin 'leafgarland/typescript-vim'  " enables TypeScript syntax-highlighting.
" Plugin 'Quramy/tsuquyomi'            " enables TypeScript auto-completion.
" JSON
" Bundle "elzr/vim-json"

" HTML
" Bundle "othree/html5.vim"

" CSS
" Bundle "hail2u/vim-css3-syntax"
" Less
" Bundle "groenewege/vim-less"

" Python
" trying out ycm instead
" Bundle "davidhalter/jedi-vim"
" Bundle "klen/python-mode"
" Bundle "Glench/Vim-Jinja2-Syntax"

" Ruby
" HAML
" (also contains sass)
" Bundle "tpope/vim-haml"
" YAML
" Bundle "ingydotnet/yaml-vim"
" Bundle "chase/vim-ansible-yaml"
" TOML
" Bundle "cespare/vim-toml"

" Clojure
" Bundle "guns/vim-sexp"
" Bundle "tpope/vim-sexp-mappings-for-regular-people"
" Bundle "guns/vim-clojure-static"
" Bundle "tpope/vim-leiningen"
" Bundle "tpope/vim-fireplace"
" Bundle "guns/vim-clojure-highlight"
" Bundle "junegunn/rainbow_parentheses.vim"

" Scala
" Bundle 'derekwyatt/vim-scala'
" Bundle 'GEverding/vim-hocon'

" Haskell
" Bundle "haskell.vim"
" Bundle "dag/vim2hs"

" Markdown / Writing
" Bundle "reedes/vim-wordy"
" Bundle "vim-pandoc/vim-pandoc"
" Bundle "vim-pandoc/vim-pandoc-syntax"
" bug in ftplugin with tabstop/shiftwidth Bundle "PProvost/vim-markdown-jekyll"
" Bundle "tpope/vim-liquid"

" Roku Brightscript
" Bundle "chooh/brightscript.vim"

" Go
" Bundle "fatih/vim-go"


filetype plugin indent on
