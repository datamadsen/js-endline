function! JSEndline#splitLine()
    let cursorPosition = getpos('.')
    let prevLine = s:getPrevNonBlankLine(line('.'))
    let prevLineLastChar = matchstr(prevLine, '.$')

    let surroundings = strpart(getline('.'), col('.') -2, 2)
    let delimiters = ["{}", "[]", "()"]

    let newlineBetweenDelimitersMovement = "\<CR>\<ESC>\<S-o>"
    let newlineMovement = "\<ESC>A\<CR>"
    let prevLineLastCharsForComma = ["{", "[", "(", ","]

    if match(delimiters, surroundings) != -1
        if match(prevLineLastCharsForComma, prevLineLastChar) != -1
            return s:replaceAndMove(",", cursorPosition, newlineBetweenDelimitersMovement)
        else
            return s:replaceAndMove(";", cursorPosition, newlineBetweenDelimitersMovement)
        endif
    endif
    return g:jsendline#splitLineMap
endfunction

function! JSEndline#newLine()
    let cursorPosition = getpos('.')

    let prevLine = s:getPrevNonBlankLine(line('.'))
    let prevLineLastChar = matchstr(prevLine, '.$')
    let nextLineLastChar = matchstr(s:getNextNonBlankLine(line('.')), '.$')
    let nextLineFirstChar = matchstr(s:strip(s:getNextNonBlankLine(line('.'))), '^.')

    let movement = "\<ESC>A\<CR>"

    if prevLineLastChar == '{'
        if s:lineContainsFunctionDeclaration(prevLine)
            return s:replaceAndMove(";", cursorPosition, movement)
        elseif nextLineFirstChar == '}'
            return s:replaceAndMove(",", cursorPosition, movement)
        endif

    elseif prevLineLastChar == '('
        if nextLineFirstChar == ')'
            return s:replaceAndMove(",", cursorPosition, movement)
        endif

    elseif prevLineLastChar == '['
        if nextLineFirstChar == ']'
            return s:replaceAndMove(",", cursorPosition, movement)
        endif

    elseif prevLineLastChar == ','
        return s:replaceAndMove(",", cursorPosition, movement)

    elseif prevLineLastChar == ';'
        return s:replaceAndMove(";", cursorPosition, movement)

    elseif prevLineLastChar == '}'
        return s:replaceAndMove(";", cursorPosition, movement)
    endif

    return jsendline#newLineMap
endfunction

function! JSEndline#cycle()
    let cursorPosition = getpos('.')
    let currentLineLastChar = matchstr(getline('.'), '.$')
    let movement = ""

    if currentLineLastChar == ';'
        return s:replaceAndMove(",", cursorPosition, movement)

    elseif currentLineLastChar == ','
        return s:replaceAndMove("", cursorPosition, movement)

    elseif currentLineLastChar != ';'
        if currentLineLastChar != ','
            return s:replaceAndMove(";", cursorPosition, movement)
        endif
    endif
    return jsendline#cycleMap
endfunction

function! s:replaceAndMove(char, cursorPosition, movement)
    exec("s/[,;]\\?$/" . a:char . "/e")
    call setpos('.', a:cursorPosition)
    if mode() == "i"
        return a:movement
    endif
    return
endfunction

function! s:justMove(cursorPosition, movement)
    call setpos('.', a:cursorPosition)
    if mode() == "i"
        return a:movement
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

function! s:lineContainsAssignment(line)
    return s:strip(a:line) =~ '^.*[:=].*$'
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

" Initialization
if exists('g:jsendline#splitLineMap')
    exec "inoremap " . g:jsendline#splitLineMap . " <C-R>=JSEndline#splitLine()<CR>"
endif

if exists('g:jsendline#newLineMap')
    exec "inoremap " . g:jsendline#newLineMap . " <C-R>=JSEndline#newLine()<CR>"
endif

if exists('g:jsendline#cycleMap')
    exec "nmap <silent> " . g:jsendline#cycleMap . " :call JSEndline#cycle()<CR>"
endif
