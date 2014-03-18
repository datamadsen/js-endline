js-eol
==========

A vim plugin that makes it easy, in normal mode, to add the typical end-of-line
characters, ';' or ',', in javascript and typescript. 

You need to map keys yourself, like this:
```vim
let g:jseol#trigger="<S-CR>"
```

Anywhere on a line, it's now possible to cycle through line ending characters
by pressing <S-CR> in normal mode, like this:

```javascript
var myMap = {}; // Press <S-CR> (in normal mode)
```
becomes:
```javascript
var myMap = {}, // Press <S-CR> (in normal mode)
```
becomes:
```javascript
var myMap = {} // Press <S-CR> (in normal mode)
```
becomes:
```javascript
var myMap = {}; // Press <S-CR> (in normal mode)
```
