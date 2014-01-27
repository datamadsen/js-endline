" Example of how to use:
" autocmd FileType javascript inoremap <silent> <S-CR> <ESC>:call vsee#vimShiftEnterSemicolonOrComma('i')<CR>
" autocmd FileType javascript nmap <silent> <S-CR> <ESC>:call vsee#vimShiftEnterSemicolonOrComma('n')<CR>

" ==============
" Main function:
" ==============

function! vsee#vimShiftEnterSemicolonOrComma(mode)
    let b:originalLineNum = line('.')
    let b:originalCursorPosition = getpos('.')

    let b:currentLine = getline(b:originalLineNum)
    let b:nextLine = s:getNextNonBlankLine(b:originalLineNum)
    let b:prevLine = s:getPrevNonBlankLine(b:originalLineNum)

    let b:prevLineLastChar = matchstr(b:prevLine, '.$')
    let b:nextLineLastChar = matchstr(b:nextLine, '.$')

    let b:nextLineFirstChar = matchstr(s:strip(b:nextLine), '^.')

    let b:surroundings = strpart(getline('.'), col('.') -1, 2)
    let delimiters = ["{}", "[]", "()"]

    if match(delimiters, b:surroundings) != -1
        let prevLineLastCharsForComma = ["{", "[", "(", ","]
    
        if b:prevLineLastChar != ''
            if match(prevLineLastCharsForComma, b:prevLineLastChar) != -1
                return s:commaEnterBetweenDelimiters(a:mode)
            else
                return s:semicolonEnterBetweenDelimiters(a:mode)
            endif
        endif
        return s:semicolonEnterBetweenDelimiters(a:mode)
    endif

    if b:prevLineLastChar == '{'
        " function hello(params) {
        "   var foo = params[0|]
        " } 
        " ->
        " function hello(params) {
        "   var foo = params[0];
        "   |
        " }
        if s:lineContainsFunctionDeclaration(b:prevLine)
            return s:semicolonEnterAfter(a:mode)
        " {
        "   foo: bar|
        " } 
        " ->
        " {
        "   foo:bar,
        "   |
        " }
        elseif b:nextLineFirstChar == '}'
            return s:commaEnterAfter(a:mode)
        endif

        " (
        "   foo|
        " ) 
        " ->
        " (
        "   foo,
        "   |
        " )
    elseif b:prevLineLastChar == '('
        if b:nextLineFirstChar == ')'
            return s:commaEnterAfter(a:mode)
        endif
     
        " [
        "   foo|
        " ]
        " ->
        " [
        "   foo,
        "   |
        " ]
    elseif b:prevLineLastChar == '['
        if b:nextLineFirstChar == ']'
            return s:commaEnterAfter(a:mode)
        endif

    " foo,
    " bar|
    " ->
    " foo,
    " bar,
    " |
    elseif b:prevLineLastChar == ','
        return s:commaEnterAfter(a:mode)
        
    " foo();
    " bar(|)
    " ->
    " foo();
    " bar();
    " |
    elseif b:prevLineLastChar == ';'
        return s:semicolonEnterAfter(a:mode)

    endif

    return s:semicolonEnterAfter(a:mode)
endfunction

" =================
" Helper functions:
" =================

function! s:commaEnterAfter(mode)
    exec("s/[,;]\\?$/,/e")
    call setpos('.', b:originalCursorPosition)
    if a:mode == "i"
        call feedkeys("A\<CR>")
    endif
    return
endfunction

function! s:semicolonEnterAfter(mode)
    exec("s/[,;]\\?$/;/e")
    call setpos('.', b:originalCursorPosition)
    if a:mode == "i"
        call feedkeys("A\<CR>")
    endif
    return
endfunction

function! s:commaEnterBetweenDelimiters(mode)
    exec("s/[,;]\\?$/,/e")
    call setpos('.', b:originalCursorPosition)
    if a:mode == "i"
        call feedkeys("a\<CR>")
    endif
    return
endfunction

function! s:semicolonEnterBetweenDelimiters(mode)
    exec("s/[,;]\\?$/;/e")
    call setpos('.', b:originalCursorPosition)
    if a:mode == "i"
        call feedkeys("a\<CR>")
    endif
    return
endfunction

function! s:strip(string)
    return substitute(a:string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! s:getNextNonBlankLineNum(lineNum)
    return s:getFutureNonBlankLineNum(a:lineNum, 1, line('$'))
endfunction

function! s:getPrevNonBlankLineNum(lineNum)
    return s:getFutureNonBlankLineNum(a:lineNum, -1, 1)
endfunction

function! s:getNextNonBlankLine(lineNum)
    return getline(s:getNextNonBlankLineNum(a:lineNum))
endfunction

function! s:getPrevNonBlankLine(lineNum)
    return getline(s:getPrevNonBlankLineNum(a:lineNum))
endfunction

function! s:lineContainsFunctionDeclaration(line)
    return s:strip(a:line) =~ '^.*function.*(.*$'
endfunction

function! s:getFutureNonBlankLineNum(lineNum, direction, limitLineNum)
    if (a:lineNum == a:limitLineNum)
        return ''
    endif

    let l:futureLineNum = a:lineNum + (1 * a:direction)
    let l:futureLine = s:strip(getline(l:futureLineNum))

    if (l:futureLine == '')
        return s:getFutureNonBlankLineNum(l:futureLineNum, a:direction, a:limitLineNum)
    endif

    return l:futureLineNum
endfunction
