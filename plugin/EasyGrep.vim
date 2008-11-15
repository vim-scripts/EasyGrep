" Title:        EasyGrep
" Author:       Dan Price
" Goal:         To be an easy to use, powerful find and replace resource for
"               intermediate to expert users
" Usage:        This file should reside in the plugin directory and be
"               automatically sourced.
"
" License:      Public domain, no restrictions whatsoever
" Contribute:   Please report any bugs or suggestions to
"               vim@danprice.fastmail.net
"
" Version:      See g:EasyGrepVersion for version number.
" History:     
"   0.2 Added option to toggle showing fewer or more options; showing fewer
"       options by default.
"       Added option '?' to print the current configuration and save it to a
"       register.
"       Now creating direct mapping by default; see g:EasyGrepNoDirectMappings
"       to turn this off.
"   0.1 Initial version
"
"
" Keymappings:
"
"    <Leader>vv  - Grep for the word under the cursor, match all occurences,
"                  like |gstar|
"    <Leader>vV  - Grep for the word under the cursor, match whole word, like 
"                  |star|
"    <Leader>va  - Like vv, but add to existing list
"    <Leader>vA  - Like vV, but add to existing list
"
"    Each of these commands will search files according to settings controlled
"    by:
"
"    <Leader>vo  - Select the files to search in and set grep options
"
" Commands:
"
"    ":Grep" - Search for the specified pattern, like <Leader>vv.  When an ! is
"    added, search like <Leader>vV
"    ":GrepAdd" - Search for the specified pattern, add to existing file list,
"    as in <Leader>va.  When an ! is added, search like <Leader>vA
"
"    ":GrepOptions" - With no parameter, open a window to set options.  With a
"    parameter, set the file pattern to the parameter Options
"
" Options:
"
"    "g:EasyGrepFileAssociations" - Specifies the location of a file that
"    contains groups of files that should be associated with one another.  When
"    set to an empty string "", no file read will be attempted.
"
"    "g:EasyGrepMode" - Specifies the mode in which to start
"    0 - All files
"    1 - Open Buffers
"    2 - Track the current extension
"
"    Note: I find option 2 to be the most powerful, but option 0 is activated by
"    default because it is the most intuitive for users who haven't take the
"    time to understand how the script works
"
"    "g:EasyGrepCommand" - Specifies the grep command to use
"    0 - vimgrep
"    1 - grep (follows grepprg)
"
"    "g:EasyGrepRecursive" - Specifies that recursive search be activated
"    on start
"
"    "g:EasyGrepHidden" - Specifies that hidden files search be activated on
"    start.  Note that hidden implies the unix meaning of those files that are
"    prepended with a '.', and not the Windows meaning of those files with a
"    hidden attribute.
"
"    "g:EasyGrepAllOptionsInExplorer" - Specifies that all options be included
"    in the explorer window
"    Note: settting this option is very useful when you want to try out and
"    learn all of the options available in this script
"
"    "g:EasyGrepWindow" - Specifies the window to use for matches
"    0 - quickfix
"    1 - location list
"
"    "g:EasyGrepOpenWindowOnMatch" - Specifies whether to open the with matches
"    after a search
"
"    "g:EasyGrepEveryMatch" - Specifies that multiple matches on the same line
"    be treated as different matches, like the g option to vimgrep
"
"    "g:EasyGrepJumpToMatch" - Specifies that jump to first match be activated,
"    like the j option to vimgrep
"
"    "g:EasyGrepInvertWholeWord" - Specifies that the whole word search keys
"    should be inverted from their default meaning.  For example, when this
"    option is activated, <Leader>vv matches whole word, while <Leader>vV
"    matches everything that includes the word.  Note that this affects both
"    keymappings and commands.
"    
"    "g:EasyGrepFileAssociationsInExplorer" - Specifies whether to include the
"    file associations when sizing the explorer window
"
"    "g:EasyGrepNoDirectMappings" - Specifies that a set of mappings be
"    generated that allow options to be set without the options explorer window

" Idea: Integrate a global find and replace with this
" Idea: allow entries in the file associations list to be regular expressions
" Idea: include special paths like $INCLUDE in the mix
" Idea: set file/directory exclusions

"
" Initialization {{{
if exists("g:EasyGrepVersion") || &cp
    finish
endif
let g:EasyGrepVersion = "0.4"
" Check for Vim version 700 or greater {{{
if v:version < 700
  echo "Sorry, EasyGrep ".g:EasyGrepVersion."\nONLY runs with Vim 7.0 and greater."
  finish
endif
" }}}
" }}}
" Helper Functions {{{
" countstr {{{
function! s:countstr(str, ele)
    let end = len(a:str)
    let c = 0
    let i = 0
    while i < end
        if a:str[i] == a:ele
            let c += 1
        endif
        let i += 1
    endwhile

    return c
endfunction
"}}}
" BackToForwardSlash {{{
function! s:BackToForwardSlash(arg)
    return substitute(a:arg, '\\', '/', 'g')
endfunction
"}}}
" GetBufferNamesList {{{
function! s:GetBufferNamesList()
    redir => bufoutput
    silent! buffers
    " This echo clears a bug in printing that shows up when it is not present
    silent! echo ""
    redir END

    let bufNames = []
    for i in split(bufoutput, '\n')
        let s1 = stridx(i, '"') + 1
        let s2 = stridx(i, '"', s1) - 1
        let str = i[s1 : s2]

        if str[0] == '[' && str[len(str)-1] == ']'
            continue
        endif

        call add(bufNames, str)
    endfor

    return bufNames
endfunction
" }}}
" OnOrOff {{{
function! s:OnOrOff(num)
    return a:num == 0 ? 'off' : 'on'
endfunction
"}}}
" Trim {{{
function! s:Trim(s)
    let len = strlen(a:s)

    let beg = 0
    while beg < len
        if a:s[beg] != " " && a:s[beg] != "\t"
            break
        endif
        let beg += 1
    endwhile

    let end = len - 1
    while end >= 0
        if a:s[end] != " " && a:s[end] != "\t"
            break
        endif
        let end -= 1
    endwhile

    return strpart(a:s, beg, end-beg+1)
endfunction
"}}}
" Warning/Error {{{
function! s:Warn(message)
    echohl WarningMsg | echomsg "[EasyGrep] ".a:message | echohl None
endfunction
function! s:Error(message)
    echohl Error | echomsg a:message | echohl None
endfunction
"}}}
" }}}
" Global Options {{{
if !exists("g:EasyGrepMode")
    let g:EasyGrepMode=0
    " 0 - All
    " 1 - Buffers
    " 2 - Track
else
    if g:EasyGrepMode > 2
        call s:Error("Invalid value for g:EasyGrepMode")
        let g:EasyGrepMode = 0
    endif
endif

if !exists("g:EasyGrepCommand")
    let g:EasyGrepCommand=0
endif

if !exists("g:EasyGrepRecursive")
    let g:EasyGrepRecursive=0
endif

if !exists("g:EasyGrepHidden")
    let g:EasyGrepHidden=0
endif

if !exists("g:EasyGrepAllOptionsInExplorer")
    let g:EasyGrepAllOptionsInExplorer=0
endif

if !exists("g:EasyGrepWindow")
    let g:EasyGrepWindow=0
endif

if !exists("g:EasyGrepOpenWindowOnMatch")
    let g:EasyGrepOpenWindowOnMatch=1
endif

if !exists("g:EasyGrepEveryMatch")
    let g:EasyGrepEveryMatch=0
endif

if !exists("g:EasyGrepJumpToMatch")
    let g:EasyGrepJumpToMatch=1
endif

if !exists("g:EasyGrepInvertWholeWord")
    let g:EasyGrepInvertWholeWord=0
endif

if !exists("g:EasyGrepFileAssociations")
    let VimfilesDir=s:BackToForwardSlash(get(split(&runtimepath, ','), 0, "noinit"))
    let g:EasyGrepFileAssociations=VimfilesDir."/plugin/EasyGrepFileAssociations"
endif

if !exists("g:EasyGrepFileAssociationsInExplorer")
    let g:EasyGrepFileAssociationsInExplorer=1
endif

if !exists("g:EasyGrepNoDirectMappings")
    let g:EasyGrepNoDirectMappings=0
endif
"}}}

" Internals {{{
" Variables {{{
let s:OptionsExplorerOpen = 0

let s:FilesToGrep="*"
let s:TrackedExt = "*"

let s:SortOptions = [ "Name", "Name Reversed", "Extension", "Extension Reversed" ]
let s:SortFunctions = [ "SortName", "SortNameReversed", "SortExtension", "SortExtensionReversed" ]
let s:SortChoice = 0

let s:Commands = [ "vimgrep", "grep" ]
let s:CommandChoice = g:EasyGrepCommand < len(s:Commands) ? g:EasyGrepCommand : 0

" }}}
" Echo {{{
function! <sid>Echo(message)
    let str = ""
    if !s:OptionsExplorerOpen
        let str .= "Easy Grep: "
    endif
    let str .= a:message
    echo str
endfunction
"}}}
" OptionsExplorer {{{
" OpenOptionsExplorer {{{
function! s:OpenOptionsExplorer()
    let s:OptionsExplorerOpen = 1

    call s:CreateOptions()

    let windowLines = len(s:Options) + 1
    if g:EasyGrepFileAssociationsInExplorer
        let windowLines += len(s:Dict)
    else
        let windowLines += s:NumSpecialOptions
    endif

    " split the window; fit exactly right
    exe "keepjumps botright ".windowLines."new"

    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal noswapfile
    setlocal cursorline

    syn match Help    /^".*/
    highlight def link Help Special

    syn match Activated    /^>\w.*/
    highlight def link Activated Type

    syn match Selection    /^\ \w.*/
    highlight def link Selection String

    nnoremap <buffer> <silent> q    :call <sid>Quit()<cr>

    nnoremap <buffer> <silent> a    :call <sid>ActivateAll()<cr>
    nnoremap <buffer> <silent> b    :call <sid>ActivateBuffers()<cr>
    nnoremap <buffer> <silent> t    :call <sid>ActivateTracked()<cr>
    nnoremap <buffer> <silent> u    :call <sid>ActivateUser()<cr>

    nnoremap <buffer> <silent> c    :call <sid>ToggleCommand()<cr>
    nnoremap <buffer> <silent> r    :call <sid>ToggleRecursion()<cr>
    nnoremap <buffer> <silent> i    :call <sid>ToggleHidden()<cr>
    nnoremap <buffer> <silent> w    :call <sid>ToggleWindow()<cr>
    nnoremap <buffer> <silent> o    :call <sid>ToggleOpenWindow()<cr>
    nnoremap <buffer> <silent> g    :call <sid>ToggleEveryMatch()<cr>
    nnoremap <buffer> <silent> p    :call <sid>ToggleJumpToMatch()<cr>
    nnoremap <buffer> <silent> !    :call <sid>ToggleWholeWord()<cr>
    nnoremap <buffer> <silent> e    :call <sid>EchoFilesSearched()<cr>
    nnoremap <buffer> <silent> s    :call <sid>Sort()<cr>
    nnoremap <buffer> <silent> ?    :call <sid>EchoOptionsSet()<cr>
    nnoremap <buffer> <silent> /    :call <sid>ToggleOptionsDisplay()<cr>
    nnoremap <buffer> <silent> <cr> :call <sid>Select()<cr>
    nnoremap <buffer> <silent> :    :call <sid>Echo("Type q to quit")<cr>

    call s:BuildPatternList()
    call s:FillWindow()
endfunction
" }}}
" Options Explorer Mapped Functions {{{
" EchoFilesSearched {{{
function! <sid>EchoFilesSearched()
    call s:BuildPatternList()

    if s:Dict[s:buffersChoicePos][2] == 1
        let str = join(split(s:FilesToGrep), "\n")
    else
        let str = ""
        let patternList = split(s:FilesToGrep)
        for p in patternList
            let s = glob(p)
            if !empty(s)
                let fileList = split(s, '\n')
                for f in fileList
                    if filereadable(f)
                        let str .= f."\n"
                    endif
                endfor
            endif
        endfor
    endif

    if !empty(str)
        call s:Echo("Files that will be searched")
        echo str
    else
        call s:Echo("No files match the current options")
    endif
endfunction
"}}}
" EchoOptionsSet {{{
function! <sid>EchoOptionsSet()

    let optList = [ 
            \ "g:EasyGrepFileAssociations",
            \ "g:EasyGrepMode",
            \ "g:EasyGrepCommand",
            \ "g:EasyGrepRecursive",
            \ "g:EasyGrepHidden",
            \ "g:EasyGrepAllOptionsInExplorer",
            \ "g:EasyGrepWindow",
            \ "g:EasyGrepOpenWindowOnMatch",
            \ "g:EasyGrepEveryMatch",
            \ "g:EasyGrepJumpToMatch",
            \ "g:EasyGrepInvertWholeWord",
            \ "g:EasyGrepFileAssociationsInExplorer",
            \ "g:EasyGrepNoDirectMappings" 
            \ ]

    let str = ""
    for item in optList
        let str .= "let ".item."=".eval(item)."\n"
    endfor

    call s:Warn("The following options will be saved in the e register; type \"ep to paste into your .vimrc")
    redir @e
    echo str
    redir END

endfunction

"}}}
" Select {{{
function! <sid>Select()
    let pos = getpos(".")
    let line = pos[1]
    let choice = line - s:firstPatternLine

    call s:ActivateChoice(choice)
endfunction
" }}}
" ActivateAll {{{
function! <sid>ActivateAll()
    call s:ActivateChoice(s:allChoicePos)
endfunction
"}}}
" ActivateBuffers {{{
function! <sid>ActivateBuffers()
    call s:ActivateChoice(s:buffersChoicePos)
endfunction
"}}}
" ActivateTracked {{{
function! <sid>ActivateTracked()
    call s:ActivateChoice(s:trackChoicePos)
endfunction
"}}}
" ActivateUser {{{
function! <sid>ActivateUser()
    call s:ActivateChoice(s:userChoicePos)
endfunction
"}}}
" ActivateChoice {{{
function! s:ActivateChoice(choice)
    let choice = a:choice

    if choice < 0 || choice == s:NumSpecialOptions
        return
    endif

    if choice < 3
        let g:EasyGrepMode = choice
    endif

    " handles the space in between the special options and file patterns
    let choice -= choice >= s:NumSpecialOptions ? 1 : 0

    let key = s:Dict[choice][0]

    let specialKeys = [ s:allChoicePos, s:buffersChoicePos, s:trackChoicePos ]

    let isActivated = (s:Dict[choice][2] != 0)
    let allBecomesActivated = 0
    if !isActivated
        if key == "User"
            let str = input("Enter Grep Pattern: ")
            if empty(str)
                if empty(s:Dict[choice][1])
                    return
                endif
            else
                let s:Dict[choice][1] = str
            endif
        elseif key == "Buffers"
            if g:EasyGrepRecursive == 1
                call s:Echo("Recursion turned off by Buffers Selection")
            endif
            let g:EasyGrepRecursive = 0
        endif

        if count(specialKeys, choice) > 0
            call s:ClearActivated()
            call s:UpdateAll()
        else
            for c in specialKeys
                if s:Dict[c][2] == 1
                    let s:Dict[c][2] = 0
                    call s:UpdateChoice(c)
                endif
            endfor
        endif

        let s:Dict[choice][2] = 1

    else
        " Ignore enter if the choice is 'All' and it is already selected
        if key != "All"
            let s:Dict[choice][2] = 0
            if s:HasActivatedItem() == 0
                let allBecomesActivated = 1
                let s:Dict[s:allChoicePos][2] = 1
                call s:UpdateChoice(s:allChoicePos)
            endif
        endif
    endif

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:UpdateChoice(choice)

    let str = ""
    if choice == s:allChoicePos
        let str = "Activated (All)"
    else
        let e = isActivated ? "Deactivated" : "Activated"

        let str = e." (".key.")"
        if allBecomesActivated
            let str .= " -> Activated (All)"
        endif
    endif

    call s:Echo(str)
endfunction
"}}}
" Sort {{{
function! <sid>Sort()
    let s:SortChoice += 1
    if s:SortChoice == len(s:SortOptions)
        let s:SortChoice = 0
    endif

    let beg = s:NumSpecialOptions
    let dictCopy = s:Dict[beg :]
    call sort(dictCopy, s:SortFunctions[s:SortChoice])
    let s:Dict[beg :] = dictCopy

    call s:UpdateOptions()
    call s:UpdateAll()

    call s:Echo("Set sort to (".s:SortOptions[s:SortChoice].")")
endfunction
" }}}
" Sort Functions {{{
function! SortName(lhs, rhs)
    return a:lhs[0] == a:rhs[0] ? 0 : a:lhs[0] > a:rhs[0] ? 1 : -1
endfunction

function! SortNameReversed(lhs, rhs)
    let r = SortName(a:lhs, a:rhs)
    return r == 0 ? 0 : r == -1 ? 1 : -1
endfunction

function! SortExtension(lhs, rhs)
    return a:lhs[1] == a:rhs[1] ? 0 : a:lhs[1] > a:rhs[1] ? 1 : -1
endfunction

function! SortExtensionReversed(lhs, rhs)
    let r = SortExtension(a:lhs, a:rhs)
    return r == 0 ? 0 : r == -1 ? 1 : -1
endfunction
" }}}
" ToggleCommand {{{
function! <sid>ToggleCommand()
    let s:CommandChoice += 1
    if s:CommandChoice == len(s:Commands)
        let s:CommandChoice = 0
    endif

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set command to (".s:Commands[s:CommandChoice].")")
endfunction
" }}}
" ToggleRecursion {{{
function! <sid>ToggleRecursion()
    let g:EasyGrepRecursive = !g:EasyGrepRecursive

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set recursive mode to (".s:OnOrOff(g:EasyGrepRecursive).")")
endfunction
" }}}
" ToggleHidden {{{
function! <sid>ToggleHidden()
    let g:EasyGrepHidden = !g:EasyGrepHidden

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set include hidden files to (".s:OnOrOff(g:EasyGrepHidden).")")
endfunction
" }}}
" ToggleWindow {{{
function! <sid>ToggleWindow()
    let g:EasyGrepWindow = !g:EasyGrepWindow
    call s:UpdateOptions()

    let WindowName = g:EasyGrepWindow==0 ? 'quickfix' : 'location list'
    call s:Echo("Set window to (".WindowName.")")
endfunction
"}}}
" ToggleOpenWindow {{{
function! <sid>ToggleOpenWindow()
    let g:EasyGrepOpenWindowOnMatch = !g:EasyGrepOpenWindowOnMatch
    call s:UpdateOptions()

    call s:Echo("Set open window on match to (".s:OnOrOff(g:EasyGrepOpenWindowOnMatch).")")
endfunction
"}}}
" ToggleEveryMatch {{{
function! <sid>ToggleEveryMatch()
    let g:EasyGrepEveryMatch = !g:EasyGrepEveryMatch
    call s:UpdateOptions()

    call s:Echo("Set seperate multiple matches to (".s:OnOrOff(g:EasyGrepEveryMatch).")")
endfunction
"}}}
" ToggleJumpToMatch {{{
function! <sid>ToggleJumpToMatch()
    let g:EasyGrepJumpToMatch = !g:EasyGrepJumpToMatch
    call s:UpdateOptions()

    call s:Echo("Set jump to match to (".s:OnOrOff(g:EasyGrepJumpToMatch).")")
endfunction
"}}}
" ToggleWholeWord {{{
function! <sid>ToggleWholeWord()
    let g:EasyGrepInvertWholeWord = !g:EasyGrepInvertWholeWord
    call s:UpdateOptions()

    call s:Echo("Set invert the meaning of whole word to (".s:OnOrOff(g:EasyGrepInvertWholeWord).")")
endfunction
"}}}
" ToggleOptionsDisplay {{{
function! <sid>ToggleOptionsDisplay()
    let g:EasyGrepAllOptionsInExplorer = !g:EasyGrepAllOptionsInExplorer

    if s:OptionsExplorerOpen
        let oldWindowLines = len(s:Options) + 1
        call s:FillWindow()
        let newWindowLines = len(s:Options) + 1

        let linesDiff = newWindowLines-oldWindowLines
        if linesDiff > 0
            let linesDiff = "+".linesDiff
        endif

        execute "resize ".linesDiff
        normal zb
    endif

    call s:Echo("Showing ". (g:EasyGrepAllOptionsInExplorer ? "more" : "fewer")." options")
endfunction
"}}}
" Quit {{{
function! <sid>Quit()
    let s:OptionsExplorerOpen = 0
    echo ""
    quit
endfunction
" }}}
"}}}
" UpdateOptions {{{
function! s:UpdateOptions()
    if !s:OptionsExplorerOpen
        return
    endif

    call s:CreateOptions()

    setlocal modifiable

    let lastLine = len(s:Options)
    let line = 0
    while line < lastLine
        call setline(line+1, s:Options[line])
        let line += 1
    endwhile

    setlocal nomodifiable
endfunction
" }}}
" UpdateAll {{{
function! s:UpdateAll()
    call s:UpdateRange(0, len(s:Dict))
endfunction
" }}}
" UpdateChoice {{{
function! s:UpdateChoice(choice)
    call s:UpdateRange(a:choice, a:choice+1)
endfunction
" }}}
" UpdateRange {{{
function! s:UpdateRange(first, last)
    if !s:OptionsExplorerOpen
        return
    endif

    setlocal modifiable
    let i = a:first
    while i < a:last
        let indicator = s:Dict[i][2] == 1 ? '>' : ' '
        let str = indicator. s:Dict[i][0] . ': ' . s:Dict[i][1]
        let lineOffset = i >= s:NumSpecialOptions ? 1 : 0
        call setline(s:firstPatternLine+i+lineOffset, str)
        let i += 1
    endwhile

    setlocal nomodifiable
endfunction
" }}}
" FillWindow {{{
function! s:FillWindow()

    setlocal modifiable

    " Clear the entire window
    execute "silent %delete"

    call s:CreateOptions()
    call append(0, s:Options)
    let s:firstPatternLine = len(s:Options) + 1
    call s:UpdateOptions()

    setlocal modifiable

    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        call append(s:firstPatternLine, "")
        let i += 1
    endwhile
    call s:UpdateAll()
    setlocal nomodifiable

    " place the cursor at the start of the special options
    execute "".len(s:Options)+1
endfunction
" }}}
" }}}
" AlreadyExists {{{
function! s:AlreadyExists(pat)
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        if s:Dict[i][0] == a:pat
            return 1
        endif
        let i += 1
    endwhile
    return 0
endfunction
" }}}
" IsRecursive {{{
function! s:IsRecursive(pattern)
    return stridx(a:pattern, "\*\*\/") == 0 ? 1 : 0
endfunction
" }}}
" BreakDown {{{
function! s:BreakDown(keyList)

    " Indicates which keys have already been parsed to avoid multiple entries
    " and infinite recursion
    let s:traversed = repeat([0], len(s:Dict))

    let str = ""
    for k in a:keyList
        let str .= s:DoBreakDown(k)." "
    endfor
    unlet s:traversed
    return str
endfunction
"}}}
" DoBreakDown {{{
function! s:DoBreakDown(key)
    if s:traversed[a:key] == 1
        return ""
    endif
    let s:traversed[a:key] = 1

    let str = ""
    let patternList = split(s:Dict[a:key][1])
    for p in patternList
        if s:IsLink(p)
            let k = s:FindByKey(s:GetKeyFromLink(p))
            if k != -1
                let str .= s:DoBreakDown(k)
            endif
        else
            let str .= p
        endif
        let str .= ' '
    endfor
    return str
endfunction
"}}}
" BuildPatternList {{{
function! s:BuildPatternList()
    if s:Dict[s:buffersChoicePos][2] == 1
        let s:FilesToGrep = join(s:GetBufferNamesList())
    elseif s:Dict[s:trackChoicePos][2] == 1

        let str = s:TrackedExt
        let i = s:FindByPattern(s:TrackedExt)
        if i != -1
            let keyList = [ i ]
            let str = s:BreakDown(keyList)
        endif

        let s:FilesToGrep = s:PostCreate(str)
    else
        let i = 0
        let numItems = len(s:Dict)
        let keyList = []
        while i < numItems
            if s:Dict[i][2] == 1
                call add(keyList, i)
            endif
            let i += 1
        endwhile

        if !empty(keyList)
            let str = s:BreakDown(keyList)
        else
            echoerr "Inconsistency in EasyGrep script"
            let str = "*"
        endif
        let s:FilesToGrep = s:PostCreate(str)
    endif
    let s:FilesToGrep = s:Trim(s:FilesToGrep)
endfunction
" }}}
" PostCreate {{{
function! s:PostCreate(str)
    if empty(a:str)
        return a:str
    endif

    let patternList = split(a:str)

    if g:EasyGrepHidden
        let i = 0
        let size = len(patternList)
        while i < size
            let item = patternList[i]
            if stridx(item, '*') != -1
                let newItem = '.'.item
                let i += 1
                let size += 1
                call insert(patternList, newItem, i)
            endif
            let i += 1
        endwhile
    endif

    let str = ""
    for item in patternList
        if g:EasyGrepRecursive && s:CommandChoice == 0
            let str .= "**/"
        endif
        let str .= item." "
    endfor

    return str
endfunction
"}}}
" ClearActivated {{{
function! s:ClearActivated()
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        let s:Dict[i][2] = 0
        let i += 1
    endwhile
endfunction
" }}}
" FindByKey {{{
function! s:FindByKey(key)
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        if s:Dict[i][0] ==# a:key
            return i
        endif
        let i += 1
    endwhile
    return -1
endfunction
" }}}
" FindByPattern {{{
function! s:FindByPattern(pattern)
    let pattern = a:pattern
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        let patterns = split(s:Dict[i][1])
        for p in patterns
            if pattern ==# p
                return i
            endif
        endfor
        let i += 1
    endwhile
    return -1
endfunction
" }}}
" HasActivatedItem {{{
function! s:HasActivatedItem()
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        if s:Dict[i][2] == 1
            return 1
        endif
        let i += 1
    endwhile
    return 0
endfunction
" }}}
" HasFilesThatMatch{{{
function! s:HasFilesThatMatch()
    let patternList = split(s:FilesToGrep)
    for p in patternList
        let fileList = split(glob(p), '\n')
        for f in fileList
            if filereadable(f)
                return 1
            endif
        endfor
    endfor
    return 0
endfunction
"}}}
" HasMatches{{{
function! s:HasMatches()
    return !empty(getqflist())
endfunction
"}}}
" CreateOptions {{{
function! s:CreateOptions()

    let s:Options = []

    call add(s:Options, "\"q: quit")
    call add(s:Options, "\"r: recursive mode (".s:OnOrOff(g:EasyGrepRecursive).")")
    call add(s:Options, "\"i: include hidden files (".s:OnOrOff(g:EasyGrepHidden).")")
    call add(s:Options, "\"e: echo files that would be searched")
    if g:EasyGrepAllOptionsInExplorer
        call add(s:Options, "\"c: change grep command (".s:Commands[s:CommandChoice].")")
        call add(s:Options, "\"w: window to use (".(g:EasyGrepWindow==0 ? 'quickfix' : 'location list').")")
        call add(s:Options, "\"o: open window on match (".s:OnOrOff(g:EasyGrepOpenWindowOnMatch).")")
        call add(s:Options, "\"g: seperate multiple matches (".s:OnOrOff(g:EasyGrepEveryMatch).")")
        call add(s:Options, "\"p: jump to match (".s:OnOrOff(g:EasyGrepJumpToMatch).")")
        call add(s:Options, "\"!: invert the meaning of whole word (".s:OnOrOff(g:EasyGrepInvertWholeWord).")")
        call add(s:Options, "\"s: change sorting (".s:SortOptions[s:SortChoice].")")
        call add(s:Options, "")
        call add(s:Options, "\"a: activate 'All' mode")
        call add(s:Options, "\"b: activate 'Buffers' mode")
        call add(s:Options, "\"t: activate 'TrackExt' mode")
        call add(s:Options, "\"u: activate 'User' mode")
        call add(s:Options, "")
        call add(s:Options, "\"?: Echo options that are set")
    endif
    call add(s:Options, "\"/: show ". (g:EasyGrepAllOptionsInExplorer ? "fewer" : "more")." options")
    call add(s:Options, "")
    call add(s:Options, "\"Current Directory: ".getcwd())
    call add(s:Options, "\"Grep Targets: ".s:FilesToGrep)
    call add(s:Options, "")

endfunction
"}}}
" CreateDict {{{
function! s:CreateDict()
    if exists("s:Dict")
        return
    endif

    let s:Dict = [ ]
    call add(s:Dict, [ "All" , "*", g:EasyGrepMode==0 ? 1 : 0 ] )
    call add(s:Dict, [ "Buffers" , "*Buffers*", g:EasyGrepMode==1 ? 1 : 0  ] )
    call add(s:Dict, [ "TrackExt" , "*TrackExt*", g:EasyGrepMode==2 ? 1 : 0  ] )
    call add(s:Dict, [ "User" , "", 0 ] )

    let s:allChoicePos = 0
    let s:buffersChoicePos = 1
    let s:trackChoicePos = 2
    let s:userChoicePos = 3

    let s:NumSpecialOptions = len(s:Dict)

    call s:ParseFileAssociationList()
    let s:NumFileAssociations = len(s:Dict) - s:NumSpecialOptions

endfunction
" }}}
" ParseFileAssociationList {{{
function! s:ParseFileAssociationList()
    if empty(g:EasyGrepFileAssociations)
        return
    endif
    if !filereadable(g:EasyGrepFileAssociations)
        call s:Error("Grep Pattern file list can't be read")
        return
    endif

    let fileList = readfile(g:EasyGrepFileAssociations)
    if empty(fileList)
        call s:Error("Grep Pattern file list is empty")
        return
    endif

    let lineCounter = 0
    for line in fileList
        let lineCounter += 1
        let line = s:Trim(line)
        if empty(line) || line[0] == "\""
            continue
        endif

        let keys = split(line, "=")
        if len(keys) != 2
            call s:Warn("Invalid line: ".line)
            continue
        endif

        let keys[0] = s:Trim(keys[0])
        let keys[1] = s:Trim(keys[1])

        " TODO: check that keys[0] is well-formed
        if len(keys[0]) == 0 || len(keys[1]) == 0
            call s:Warn("Invalid line: ".line)
        endif

        if s:AlreadyExists(keys[0])
            call s:Warn("Key already added: ".keys[0])
            continue
        endif

        let pList = split(keys[1])
        for p in pList


            " TODO: check for invalid filesystem characters.  this is probably
            " different for different systems.  Make sure the list is complete
            if match(p, "[/\\,;']") != -1
                call s:Warn("Invalid pattern (".p.") in line(".lineCounter.")")
                continue
            endif

            if match(p, '[<>]') != -1
                if    s:countstr(p, '<') > 1   
                \  || s:countstr(p, '>') > 1
                \  || p[0] != '<'
                \  || p[len(p)-1] != '>'  
                    call s:Warn("Invalid link (".p.") in line(".lineCounter.")")
                    continue
                endif
            endif
        endfor

        call add(s:Dict, [ keys[0], keys[1], 0 ] )
    endfor
    call s:CheckLinks()
endfunction
"}}}
" IsLink {{{
function! s:IsLink(str)
    return a:str[0] == '<' && a:str[len(a:str)-1] == '>'
endfunction
"}}}
" GetKeyFromLink {{{
function! s:GetKeyFromLink(str)
    return strpart(a:str, 1, len(a:str)-2)
endfunction
"}}}
" CheckLinks {{{
function! s:CheckLinks()
    let i = s:NumSpecialOptions
    let end = len(s:Dict)
    while i < end
        let patterns = split(s:Dict[i][1])
        let j = 0
        for p in patterns
            if s:IsLink(p) && s:FindByKey(s:GetKeyFromLink(p)) == -1
                call s:Warn("Key(".p.") links to a nonexistent key")
                call remove(patterns, j)
                let j -= 1
            endif
            let j += 1
        endfor

        if len(patterns) == 0
            call s:Warn("Key(".s:Dict[i][0].") has no valid patterns or links")
            call remove(s:Dict, i)
        else
            let s:Dict[i][1] = join(patterns)
        endif
        let i += 1
    endwhile
endfunction
"}}}
" SetCurrentExtension {{{
function! s:SetCurrentExtension()
    if !empty(&buftype)
        return
    endif
    let ext = fnamemodify(bufname("%"), ":e")
    if !empty(ext)
        let s:TrackedExt = "*.".ext
    endif
endfunction
"}}}
" SetWatchExtension {{{
function! s:SetWatchExtension()
    call s:CreateDict()
    augroup EasyGrepAutocommands
        au!
        autocmd BufWinEnter * call s:SetCurrentExtension()
    augroup END
    " Note: the autocmd is necessary to best track the users intentions.  The
    " reason for this is that the user could do a search from a file without an
    " extension and then the best case is to simply use the last extension
    " tracked.  If that last extension, however, were to be picked up from the
    " last search, then situations could arise where confusing behavior is
    " encountered.
    "
    " e.g. User searches from a .txt file; .txt is registered.  User navigates
    " to a .sh file.  The user then issues a search (by keyed command or
    " explicit command) from the quickfix window, expecting .sh files to be
    " searched, but because the search was not invoked from a file/buffer
    " without an extension, the last tracked extension is used, which is a .txt,
    " and against the expectation that it be a .sh file.
endfunction
call s:SetWatchExtension()
"}}}
" CreateDirectMappings {{{
function! s:CreateDirectMappings()
    " Note: I chose <leader>vy because I found it easy to type
    " if you want a mnemonic for it, think of (y)our own 

    nmap <silent> <leader>vya    :call <sid>ActivateAll()<cr>
    nmap <silent> <leader>vyb    :call <sid>ActivateBuffers()<cr>
    nmap <silent> <leader>vyt    :call <sid>ActivateTracked()<cr>
    nmap <silent> <leader>vyu    :call <sid>ActivateUser()<cr>

    nmap <silent> <leader>vyc    :call <sid>ToggleCommand()<cr>
    nmap <silent> <leader>vyr    :call <sid>ToggleRecursion()<cr>
    nmap <silent> <leader>vyi    :call <sid>ToggleHidden()<cr>
    nmap <silent> <leader>vyw    :call <sid>ToggleWindow()<cr>
    nmap <silent> <leader>vyo    :call <sid>ToggleOpenWindow()<cr>
    nmap <silent> <leader>vyg    :call <sid>ToggleEveryMatch()<cr>
    nmap <silent> <leader>vyp    :call <sid>ToggleJumpToMatch()<cr>
    nmap <silent> <leader>vy!    :call <sid>ToggleWholeWord()<cr>
    nmap <silent> <leader>vye    :call <sid>EchoFilesSearched()<cr>
    nmap <silent> <leader>vys    :call <sid>Sort()<cr>
    nmap <silent> <leader>vy/    :call <sid>ToggleOptionsDisplay()<cr>
    nmap <silent> <leader>vy?    :call <sid>EchoOptionsSet()<cr>
endfunction
"}}}
" GrepCurrentWord {{{
function! <sid>GrepCurrentWord(add, whole)
    let currWord=expand("<cword>")
    if empty(currWord)
        call s:Warn("No current word")
        return
    endif
    call s:DoGrep(currWord, a:add, a:whole, "")
endfunction
" }}}
" ReplaceCurrentWord {{{
"function! <sid>ReplaceCurrentWord(whole)
    "let currWord=expand("<cword>")
    "if empty(currWord)
        "call s:Warn("No current word")
        "return
    "endif

    "let r = input("Replace '".currWord."' with: ")
    "if empty(r)
        "return
    "endif

    "" TODO: this should return a value
    "call s:DoGrep(currWord, "", a:whole)
    "if !s:HasMatches()
        "return
    "endif
    ""let qflist = getqflist()
    ""if empty(qflist)
        ""return
    ""endif

    "" TODO: parameterize the flags
    "" TODO: improve this snippet
    "" TODO: consider that this might save all of the files, making it hard to
    "" undo the changes
    " Note: the implementation of the functionality below was inspired by the
    " vgrepsup plugin
    "while 1
        "silent exe 's/'.escape(currWord, '/').'/'.escape(r,'/').'/gc'
        "try
            "silent cnext
        "catch
            "if v:exception !~ 'E553:' | echoerr v:exception | endif
            "break
        "endtry
    "endwhile

"endfunction
"}}}
" GrepInput {{{
function! s:GrepInput(word, add, bang, count)
    call s:DoGrep( a:word , a:add, a:bang == "!" ? 1 : 0, a:count>0 ? a:count : "")
endfunction
" }}}
" GrepSetManual {{{
function! s:GrepSetManual(str)
    let str = a:str
    if s:IsRecursive(str)
        call s:Error("User specified grep pattern may not have a recursive specifier")
        return
    endif
    let userPos = s:FindByKey("User")
    let pos = userPos

    let i = s:FindByPattern(str)
    if i != -1
        let s2 = s:Dict[i][1]
        if str == s2
            let pos = i
        else
            let msg = "Pattern '".s:Dict[i][0]."=".s:Dict[i][1]."' matches your input, use this?"
            let response = confirm(msg, "&Yes\n&No")
            if response == 1
                let pos = i
            endif
        endif
    endif

    call s:ClearActivated()

    if pos == userPos
        let s:Dict[pos][1] = str
    endif
    let s:Dict[pos][2] = 1
endfunction
"}}}
" GrepOptions {{{
function! <sid>GrepOptions(...)
    call s:CreateDict()

    if a:0 > 0
        call s:GrepSetManual(a:1)
    else
        call s:OpenOptionsExplorer()
    endif
endfunction
" }}}
" DoGrep {{{
function! s:DoGrep(word, add, whole, count)
    call s:CreateDict()

    if s:OptionsExplorerOpen == 1
        call s:Error("Error: Can't Grep while options window is open")
        return
    endif

    let com = s:Commands[s:CommandChoice]

    let commandIsVimgrep = (com == "vimgrep")
    let commandIsGrep = !commandIsVimgrep && (stridx(&grepprg, "grep ") == 0)
    let commandIsFindstr = !commandIsVimgrep && (stridx(&grepprg, "findstr ") == 0)

    let s1 = ""
    let s2 = ""
    if commandIsVimgrep
        let s1 = "/"
        let s2 = "/"

        if g:EasyGrepEveryMatch
            let s2 .= "g"
        endif

        if g:EasyGrepJumpToMatch
            let s2 .= "j"
        endif
    endif

    let opts = ""

    if g:EasyGrepInvertWholeWord
        let whole = !a:whole
    else
        let whole = a:whole
    endif

    let word = a:word
    if whole
        if commandIsVimgrep
            let word = "\\<".a:word."\\>"
        elseif commandIsGrep
            let word = "-w ".a:word
        elseif commandIsFindstr
            let word = "\"\\<".a:word."\\>\""
        endif
    endif

    if g:EasyGrepRecursive
        if commandIsGrep
            let opts .= "-R "
        elseif commandIsFindstr
            let opts .= "/S "
        endif
    endif

    call s:BuildPatternList()
    if s:Dict[s:buffersChoicePos][2] == 1 && empty(s:FilesToGrep)
        call s:Warn("No saved buffers to explore")
        return
    " Don't evaluate if in recursive mode, this will take too long
    elseif g:EasyGrepRecursive == 0 && !s:HasFilesThatMatch()
        call s:Warn("No files match against ".s:FilesToGrep)
        return
    endif
    let win = g:EasyGrepWindow != 0 ? "l" : ""

    " TODO: consider try-ing this and catching the error rather than having the
    " check above
    execute a:count.win.com.a:add." ".opts." ".s1.word.s2." ".s:FilesToGrep

    if s:HasMatches()
        if g:EasyGrepOpenWindowOnMatch
            if g:EasyGrepWindow == 0
                cwindow
            else
                lwindow
            endif
        endif
    endif
endfunction
" }}}
" }}}

" Commands {{{
command! -count -bang -nargs=1 Grep :call s:GrepInput( <f-args> , "", "<bang>", "<count>")
command! -count -bang -nargs=1 GrepAdd :call s:GrepInput( <f-args>, "add", "<bang>", "<count>")
command! -nargs=? GrepOptions :call <sid>GrepOptions( <f-args> )
"}}}
" Keymaps {{{
if !hasmapto("<plug>EgMapGrepOptions")
    map <silent> <Leader>vo <plug>EgMapGrepOptions
endif
if !hasmapto("<plug>EgMapGrepCurrentWordv")
    map <silent> <Leader>vv <plug>EgMapGrepCurrentWordv
endif
if !hasmapto("<plug>EgMapGrepCurrentWordV")
    map <silent> <Leader>vV <plug>EgMapGrepCurrentWordV
endif
if !hasmapto("<plug>EgMapGrepCurrentWorda")
    map <silent> <Leader>va <plug>EgMapGrepCurrentWorda
endif
if !hasmapto("<plug>EgMapGrepCurrentWordA")
    map <silent> <Leader>vA <plug>EgMapGrepCurrentWordA
endif
"if !hasmapto("<plug>EgMapReplaceCurrentWord")
    "map <silent> <Leader>vr <plug>EgMapReplaceCurrentWordr
"endif
"if !hasmapto("<plug>EgMapReplaceCurrentWord")
    "map <silent> <Leader>vR <plug>EgMapReplaceCurrentWordR
"endif

nmap <silent> <unique> <script> <plug>EgMapGrepOptions      :call <sid>GrepOptions()<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWordv :call <sid>GrepCurrentWord("", 0)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWordV :call <sid>GrepCurrentWord("", 1)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWorda :call <sid>GrepCurrentWord("add", 0)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWordA :call <sid>GrepCurrentWord("add", 1)<CR>
"nmap <silent> <unique> <script> <plug>EgMapReplaceCurrentWordr :call <sid>ReplaceCurrentWord(0)<CR>
"nmap <silent> <unique> <script> <plug>EgMapReplaceCurrentWordR :call <sid>ReplaceCurrentWord(1)<CR>

if !g:EasyGrepNoDirectMappings
    call s:CreateDirectMappings()
endif
"}}}


