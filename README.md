vim-shift-enter-endline
=======================

A vim plugin that inserts the proper line ending character and then inserts a
new line, either after that character or on the cursors current position. Made
with javascript in mind.

For instance:

```javascript
function hello(params) {
    var foo = params[0|]
} 
```

becomes:

```javascript
function hello(params) {
    var foo = params[0];
    |
} 
```

and: 

```javascript
var myMap = {|} 
```

becomes:

```javascript
var myMap = {
};
```

You can map both insert and normal mode Shift-Enter to trigger the plugin:

```vim
autocmd FileType javascript inoremap <silent> <S-CR> <ESC>:call vsee#vimShiftEnterSemicolonOrComma()<CR>
autocmd FileType javascript nmap <silent> <S-CR> <ESC>:call vsee#vimShiftEnterSemicolonOrComma()<CR>
```
