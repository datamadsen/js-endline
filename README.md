js-endline
==========

A vim plugin that takes a guess at, and inserts, the proper line ending
character and then inserts a new line, either after that character or on the
cursors current position. The plugin is made with javascript in mind, and can
do three things:

* Add line ending character and opens a new line below the current.

* Add line ending character and "split" the current line and make sure that the
  cursor is properly placed afterwards (remember to :set autoindent).

* Cycle through line ending characters if the guess in one of the above wasn't
  good enough (that would be a bug - feel free to report and fix bugs).

You need to map keys yourself, like this:
```vim
autocmd FileType javascript nmap <silent> <S-CR> :call JSEndline#cycle()<CR>
autocmd FileType javascript inoremap <S-CR> <C-R>=JSEndline#newLine()<CR>
autocmd FileType javascript inoremap <CR> <C-R>=JSEndline#splitLine()<CR>
```

With the above mappings, this:

```javascript
function hello(params) {
    var foo = params[0|] // Press <S-CR>
} 
```

becomes:

```javascript
function hello(params) {
    var foo = params[0];
    |
} 
```

and this: 

```javascript
var myMap = {|} // Press <CR>
```

becomes:

```javascript
var myMap = {
    |
};
```

If the plugin makes the wrong guess, it's possible to cycle through line ending
characters by pressing <S-CR> in normal mode, like this:

```javascript
var myMap = {}; // Press <S-CR>
```
becomes:
```javascript
var myMap = {}, // Press <S-CR>
```
becomes:
```javascript
var myMap = {} // Press <S-CR>
```
becomes:
```javascript
var myMap = {}; // Press <S-CR>
```

And so on.

The plugin makes use of a bunch of helper functions from
[cosco.vim](https://github.com/lfilho/cosco.vim).
