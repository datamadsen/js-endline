" Example of how to use:
"autocmd FileType javascript nmap <silent> <S-CR> :call JSEndline#cycle()<CR>
"autocmd FileType javascript inoremap <S-CR> <C-R>=JSEndline#newLine()<CR>
"autocmd FileType javascript inoremap <CR> <C-R>=JSEndline#splitLine()<CR>

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
        if prevLineLastChar != ''
            if prevLineLastChar == ';'
            elseif !s:lineContainsAssignment(getline(line('.')))
                return s:justMove(cursorPosition, newlineBetweenDelimitersMovement)
            elseif match(prevLineLastCharsForComma, prevLineLastChar) != -1
                if s:lineContainsFunctionDeclaration(prevLine)
                    return s:replaceAndMove(";", cursorPosition, newlineBetweenDelimitersMovement)
                else
                    return s:replaceAndMove(",", cursorPosition, newlineBetweenDelimitersMovement)
                endif
            else
                if !s:lineContainsFunctionDeclaration(prevLine)
                    return s:replaceAndMove(";", cursorPosition, newlineBetweenDelimitersMovement)
                endif
            endif
        endif
    endif
    return s:justMove(cursorPosition, newlineBetweenDelimitersMovement)
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

" =================
" Helper functions:
" =================
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
