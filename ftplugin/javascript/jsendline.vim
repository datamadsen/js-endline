function! JSEndline#splitLine()
    let cursorPosition = getpos('.')
    let prevLine = s:getPrevNonBlankLine(line('.'))
    let prevLineLastChar = matchstr(prevLine, '.$')

    let currentLineIsBlank = s:strip(getline('.')) == ''

    let surroundings = strpart(getline('.'), col('.') -2, 2)
    let delimiters = ["{}", "[]", "()"]

    let newlineBetweenDelimitersMovement = "\<CR>\<ESC>\<S-o>"
    let prevLineLastCharsForComma = ["{", "[", "(", ","]

    if !currentLineIsBlank
        if index(delimiters, surroundings) != -1
            if index(prevLineLastCharsForComma, prevLineLastChar) != -1
                if prevLine == ""
                    return s:replaceAndMove(";", cursorPosition, newlineBetweenDelimitersMovement)
                else
                    return s:replaceAndMove(",", cursorPosition, newlineBetweenDelimitersMovement)
                endif
            else
                return s:replaceAndMove(";", cursorPosition, newlineBetweenDelimitersMovement)
            endif
        endif
    endif

    return s:justMove(cursorPosition, "\<CR>")
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

    return s:justMove(cursorPosition, movement)
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
if exists('g:jsendline#splitLineTrigger')
    exec "inoremap " . g:jsendline#splitLineTrigger . " <C-R>=JSEndline#splitLine()<CR>"
endif

if exists('g:jsendline#newLineTrigger')
    exec "inoremap " . g:jsendline#newLineTrigger . " <C-R>=JSEndline#newLine()<CR>"
endif

if exists('g:jsendline#cycleTrigger')
    exec "nmap <silent> " . g:jsendline#cycleTrigger . " :call JSEndline#cycle()<CR>"
endif
