function! JSEol#Eol(newline)
    let cursorPosition = getpos('.')
    let currentLineLastChar = matchstr(getline('.'), '.$')

    if a:newline == 1
        let movement = "\<ESC>A\<CR>"
        return s:replaceAndMove(";", cursorPosition, movement)
    else
        let movement = ""
    endif

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
if exists('g:jseol#insertModeTrigger')
    exec "inoremap " . g:jseol#insertModeTrigger . " <C-R>=JSEol#Eol(1)<CR>"
endif

if exists('g:jseol#normalModeTrigger')
    exec "nmap <silent> " . g:jseol#normalModeTrigger . " :call JSEol#Eol(0)<CR>"
endif
