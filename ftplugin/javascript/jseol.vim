function! JSEol#Eol()
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

" Initialization
if exists('g:jseol#normalModeTrigger')
    exec "nmap <silent> " . g:jseol#normalModeTrigger . " :call JSEol#Eol()<CR>"
endif
