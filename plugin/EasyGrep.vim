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
"   0.9 Feature: Added forward slash delineated pattern to the Replace command
"       e.g. :Replace /target/replacement/
"       that allows more complicated replacements; you can now work with
"       patterns that have spaces in them.
"       Bugfix: If cursorline is off at the start of a replace, now ensuring
"       that cursorline is turned off for all buffers, and not just the last one
"       Bugfix: fixed an issue with an extra tab being opened during a
"       replacement
"   0.8 Implemented case sensitivity that is independent of ignorecase, thanks
"       to Doro Wu for contributing to this functionality
"       Changed shortcut key for hidden files from 'i' to 'h'
"   0.7 Expanded search of EasyGrepFileAssociations list to every component of
"       'runtimepath'.  This solves a starting message for those who placed
"       EasyGrepFileAssociations in a location other than the first location in
"       'runtimepath'.
"   0.6 Fixed paths with spaces in them
"       Folds will now be disabled where replacements are to be made
"       Fixed an error with checking for extra warnings
"       Better highlighting while replacing
"       Recursive mode can no longer be activated when Buffers mode is activated
"   0.5 Fixed an issue with tracking the file extension where sometimes the
"       desired extension wouldn't be registered.
"       Better reporting when no files match.
"       Now warning when searching from a working directory that doesn't match
"       the current file's directory.
"       Added g:EasyGrepExtraWarnings option.
"   0.4 Improved Replace and ReplaceUndo
"       Added two configurable modes for how the windows operate when doing a
"       global replace.
"       Fixed an issue with linked filetypes.
"   0.3 Added experimental :Replace and :ReplaceUndo commands; keymapped 
"       <leader>vr for :Replace
"       Improved response when no matches
"   0.2 Added option to toggle showing fewer or more options; showing fewer
"       options by default.
"       Added option '?' to print the current configuration and save it to a
"       register.
"       Now creating direct mappings by default; see g:EasyGrepNoDirectMappings
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
"    <Leader>vr  - Perform a global search search on the word under the cursor
"                  and prompt for a pattern with which to replace it.
"
"    Each of the above commands will search files according to settings
"    controlled by:
"
"    <Leader>vo  - Select the files to search in and set grep options
"
"    For each of the options presented in this window, there is a mapping that
"    allows a direct change of this option.  The pattern is <Leader>vy* , where
"    star is the value listed in the options window for each of the options.
"    See g:EasyGrepNoDirectMappings to turn this off.
"
"    Note: These keymappings may be remapped to your liking; see the end of the
"    file for the associated plugin mappings
"
" Commands:
"
"    ":Grep [arg]"
"        Search for the specified arg, like <Leader>vv.  When an ! is added,
"        search like <Leader>vV
"
"    ":GrepAdd [arg]" 
"        Search for the specified arg, add to existing file list, as in
"        <Leader>va.  When an ! is added, search like <Leader>vA
"
"    ":Replace [target] [replacement]"
"        Perform a global search and replace.  The function searches
"        the same set of files a grep for the desired target and opens a dialog to
"        confirm replacement.
"    
"    ":ReplaceUndo" 
"        Undoes the last :Replace operation.  Does not stack successive
"        searches; only the last replace may be undone.  This function may not
"        work well when edits are made between a call to Replace and a call to
"        ReplaceUndo.
"
"    ":GrepOptions [arg]" 
"        With no arg, open a window to set options.  With an arg, set the file
"        pattern to arg.
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
"    "g:EasyGrepIgnoreCase" - Specifies the case sensitivity of searches.  Note
"    that this can be further overrided for vimgrep searches with \c and \C
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
"
"    "g:EasyGrepReplaceWindowMode" - Specifies the mode that the script will use
"    when a buffer needs to be changed while performing a global replace.
"    0 - Open a new tab for each window
"    1 - Perform a split of the current window with the next window
"    2 - autowriteall; create no new windows
"
"    Note: Option 1 has the possibility of running out of vertical space to
"    split more windows.  Actions are taken to make this a non-issue, but this
"    option can often be more clunky than other options.
"    Note: As a result of the limitation above, option 0 is the only mode that
"    won't require saving the files during a replace
"
"    "g:EasyGrepReplaceAllPerFile" - Specifies that selecting 'a' (for all) will
"    apply the replacements on a per file basis, as opposed to globally as is
"    the default.
"
"    "g:EasyGrepExtraWarnings" - Specifies that warnings be issued for 
"    conditions that may be valid but confuse some users.

" Idea: allow entries in the file associations list to be regular expressions
" Idea: include special paths like $INCLUDE in the mix
" Idea: set file/directory exclusions
" Idea: make sure that regex search and replace works as expected
" Idea: remove location list options?
" Idea: experiment with undo in ReplaceUndo instead of currently
"       implemented substitute; this is challenging though as the user may make
"       changes in between a call to Replace and ReplaceUndo
"
" TODO: increase the granularity of the match so that you can individually
"       decide per line
" FIXME: cursorline doesn't always follow to the line at which the replacement
"        is going to happen
" FIXME: ReplaceUndo can't currently replace the text accurately in all cases if
"        case insensitivity is turned on

"
" Initialization {{{
if exists("g:EasyGrepVersion") || &cp || !has("quickfix")
    finish
endif
let g:EasyGrepVersion = "0.9"
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
" unique {{{
function! s:unique(lst)
    if empty(a:lst)
        return a:lst
    endif

    let lst = a:lst
    call sort(lst)

    let end = len(lst)
    let i = 1
    let lastSeen = lst[0]
    while i < end
        if lst[i] == lastSeen
            call remove(lst, i)
            let end -= 1
        else
            let i += 1
        endif
    endwhile

    return lst
endfunction
"}}}
" BackToForwardSlash {{{
function! s:BackToForwardSlash(arg)
    return substitute(a:arg, '\\', '/', 'g')
endfunction
"}}}
" GetBuffersOutput {{{
function! s:GetBuffersOutput()
    redir => bufoutput
    silent! buffers
    " This echo clears a bug in printing that shows up when it is not present
    silent! echo ""
    redir END

    return bufoutput
endfunction
" }}}
" GetBufferIdList {{{
function! s:GetBufferIdList()
    let bufoutput = s:GetBuffersOutput()

    let bufids = []
    for i in split(bufoutput, '\n')
        let s1 = 0
        while i[s1] == ' '
            let s1 += 1
        endwhile

        let s2 = stridx(i, ' ', s1) - 1
        let id = str2nr(i[s1 : s2])

        call add(bufids, id)
    endfor

    return bufids
endfunction
" }}}
" GetBufferNamesList {{{
function! s:GetBufferNamesList()
    let bufoutput = s:GetBuffersOutput()

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
" GetVisibleBuffers {{{
function! s:GetVisibleBuffers()
    let tablist = []
    for i in range(tabpagenr('$'))
       call extend(tablist, tabpagebuflist(i + 1))
    endfor
    let tablist = s:unique(tablist)
    return tablist
endfunction
" }}}
" EscapeList {{{
function! s:FileEscape(item)
    return escape(a:item, ' \')
endfunction
function! s:ShellEscape(item)
    return shellescape(a:item, 1)
endfunction
function! s:DoEscapeList(lst, seperator, func)
    let escapedList = []
    for item in a:lst
        let e = a:func(item).a:seperator
        call add(escapedList, e)
    endfor
    return escapedList
endfunction
function! s:EscapeList(lst, seperator)
    return s:DoEscapeList(a:lst, a:seperator, function("s:FileEscape"))
endfunction
function! s:ShellEscapeList(lst, seperator)
    return s:DoEscapeList(a:lst, a:seperator, function("s:ShellEscape"))
endfunction
"}}}
" GetSavedName {{{
function! s:GetSavedName(var)
    return "s:saved_".a:var
endfunction
" }}}
" SaveVariable {{{
function! s:SaveVariable(var)
    let savedName = s:GetSavedName(a:var)
    execute "let ".savedName." = &".a:var
endfunction
" }}}
" RestoreVariable {{{
" if a second variable is present, indicate no unlet
function! s:RestoreVariable(var, ...)
    let doUnlet = a:0 == 1
    let savedName = s:GetSavedName(a:var)
    if exists(savedName)
        execute "let &".a:var." = ".savedName
        if doUnlet
            unlet savedName
        endif
    endif
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
function! s:Warning(message)
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

if !exists("g:EasyGrepIgnoreCase")
    let g:EasyGrepIgnoreCase=&ignorecase
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

" GetAssociationFileList {{{
function! s:GetFileAssociationList()
    if exists("g:EasyGrepFileAssociations")
        return g:EasyGrepFileAssociations
    endif

    let VimfilesDirs=split(&runtimepath, ',')
    for v in VimfilesDirs
        let f = s:BackToForwardSlash(v)."/plugin/EasyGrepFileAssociations"
        if filereadable(f)
            let g:EasyGrepFileAssociations=f
            return f
        endif
    endfor

    call s:Error("Grep Pattern file list can't be read")
    let g:EasyGrepFileAssociations=""
    return ""
endfunction
" }}}

if !exists("g:EasyGrepFileAssociationsInExplorer")
    let g:EasyGrepFileAssociationsInExplorer=1
endif

if !exists("g:EasyGrepNoDirectMappings")
    let g:EasyGrepNoDirectMappings=0
endif

if !exists("g:EasyGrepReplaceWindowMode")
    let g:EasyGrepReplaceWindowMode=0
else
    if g:EasyGrepReplaceWindowMode > 2
        call s:Error("Invalid value for g:EasyGrepReplaceWindowMode")
        let g:EasyGrepReplaceWindowMode = 0
    endif
endif

if !exists("g:EasyGrepReplaceAllPerFile")
    let g:EasyGrepReplaceAllPerFile=0
endif

if !exists("g:EasyGrepExtraWarnings")
    let g:EasyGrepExtraWarnings=1
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

    nnoremap <buffer> <silent> l    <Nop>
    nnoremap <buffer> <silent> q    :call <sid>Quit()<cr>

    nnoremap <buffer> <silent> a    :call <sid>ActivateAll()<cr>
    nnoremap <buffer> <silent> b    :call <sid>ActivateBuffers()<cr>
    nnoremap <buffer> <silent> t    :call <sid>ActivateTracked()<cr>
    nnoremap <buffer> <silent> u    :call <sid>ActivateUser()<cr>

    nnoremap <buffer> <silent> c    :call <sid>ToggleCommand()<cr>
    nnoremap <buffer> <silent> r    :call <sid>ToggleRecursion()<cr>
    nnoremap <buffer> <silent> i    :call <sid>ToggleIgnoreCase()<cr>
    nnoremap <buffer> <silent> h    :call <sid>ToggleHidden()<cr>
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
    call s:BuildPatternList("\n")

    if s:Dict[s:buffersChoicePos][2] == 1
        let str = s:FilesToGrep
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
            \ "g:EasyGrepIgnoreCase",
            \ "g:EasyGrepHidden",
            \ "g:EasyGrepAllOptionsInExplorer",
            \ "g:EasyGrepWindow",
            \ "g:EasyGrepOpenWindowOnMatch",
            \ "g:EasyGrepEveryMatch",
            \ "g:EasyGrepJumpToMatch",
            \ "g:EasyGrepInvertWholeWord",
            \ "g:EasyGrepFileAssociationsInExplorer",
            \ "g:EasyGrepNoDirectMappings",
            \ "g:EasyGrepReplaceWindowMode",
            \ "g:EasyGrepReplaceAllPerFile" 
            \ ]

    let str = ""
    for item in optList
        let str .= "let ".item."=".eval(item)."\n"
    endfor

    call s:Warning("The following options will be saved in the e register; type \"ep to paste into your .vimrc")
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
    if s:Dict[s:buffersChoicePos][2] == 1
        call s:Warning("Recursive mode cant' be set when *Buffers* is activated")
        return
    endif

    let g:EasyGrepRecursive = !g:EasyGrepRecursive

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set recursive mode to (".s:OnOrOff(g:EasyGrepRecursive).")")
endfunction
" }}}
" ToggleIgnoreCase {{{
function! <sid>ToggleIgnoreCase()
    let g:EasyGrepIgnoreCase = !g:EasyGrepIgnoreCase
    call s:UpdateOptions()
    call s:Echo("Set ignore case to (".s:OnOrOff(g:EasyGrepIgnoreCase).")")
endfunction
" }}}
" ToggleHidden {{{
function! <sid>ToggleHidden()
    let g:EasyGrepHidden = !g:EasyGrepHidden

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set hidden files included to (".s:OnOrOff(g:EasyGrepHidden).")")
endfunction
" }}}
" ToggleWindow {{{
function! <sid>ToggleWindow()
    let g:EasyGrepWindow = !g:EasyGrepWindow
    call s:UpdateOptions()

    call s:Echo("Set window to (".s:GetErrorListName().")")
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
function! s:BuildPatternList(...)
    if a:0 > 0
        let sp = a:1
    else
        let sp = " "
    endif

    if s:Dict[s:buffersChoicePos][2] == 1
        let s:FilesToGrep = join(s:EscapeList(s:GetBufferNamesList(), " "), sp)
    elseif s:Dict[s:trackChoicePos][2] == 1

        let str = s:TrackedExt
        let i = s:FindByPattern(s:TrackedExt)
        if i != -1
            let keyList = [ i ]
            let str = s:BreakDown(keyList)
        endif

        let s:FilesToGrep = s:PostCreate(str, sp)
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
        let s:FilesToGrep = s:PostCreate(str, sp)
    endif
    let s:FilesToGrep = s:Trim(s:FilesToGrep)
endfunction
" }}}
" PostCreate {{{
function! s:PostCreate(str, sp)
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
        let str .= item.a:sp
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
    let saveFilesToGrep = s:FilesToGrep

    call s:BuildPatternList("\n")
    let patternList = split(s:FilesToGrep, '\n')
    for p in patternList
        let fileList = split(glob(p), '\n')
        for f in fileList
            if filereadable(f)
                let s:FilesToGrep = saveFilesToGrep
                return 1
            endif
        endfor
    endfor

    let s:FilesToGrep = saveFilesToGrep
    return 0
endfunction
"}}}
" HasMatches{{{
function! s:HasMatches()
    return !empty(s:GetErrorList())
endfunction
"}}}
" GetErrorList {{{
function! s:GetErrorList()
    if g:EasyGrepWindow == 0
        return getqflist()
    else
        return getloclist(0)
    endif
endfunction
"}}}
" GetErrorListName {{{
function! s:GetErrorListName()
    if g:EasyGrepWindow == 0
        return 'quickfix'
    else
        return 'location list'
    endif
endfunction
"}}}
" CreateOptions {{{
function! s:CreateOptions()

    let s:Options = []

    call add(s:Options, "\"q: quit")
    call add(s:Options, "\"r: recursive mode (".s:OnOrOff(g:EasyGrepRecursive).")")
    call add(s:Options, "\"i: ignore case (".s:OnOrOff(g:EasyGrepIgnoreCase).")")
    call add(s:Options, "\"h: hidden files included (".s:OnOrOff(g:EasyGrepHidden).")")
    call add(s:Options, "\"e: echo files that would be searched")
    if g:EasyGrepAllOptionsInExplorer
        call add(s:Options, "\"c: change grep command (".s:Commands[s:CommandChoice].")")
        call add(s:Options, "\"w: window to use (".s:GetErrorListName().")")
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
    let lst = s:GetFileAssociationList()

    if empty(lst)
        return
    endif

    if !filereadable(lst)
        call s:Error("Grep Pattern file list can't be read")
        return
    endif

    let fileList = readfile(lst)
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
            call s:Warning("Invalid line: ".line)
            continue
        endif

        let keys[0] = s:Trim(keys[0])
        let keys[1] = s:Trim(keys[1])

        " TODO: check that keys[0] is well-formed
        if len(keys[0]) == 0 || len(keys[1]) == 0
            call s:Warning("Invalid line: ".line)
        endif

        if s:AlreadyExists(keys[0])
            call s:Warning("Key already added: ".keys[0])
            continue
        endif

        let pList = split(keys[1])
        for p in pList


            " TODO: check for invalid filesystem characters.  this is probably
            " different for different systems.  Make sure the list is complete
            if match(p, "[/\\,;']") != -1
                call s:Warning("Invalid pattern (".p.") in line(".lineCounter.")")
                continue
            endif

            if match(p, '[<>]') != -1
                if    s:countstr(p, '<') > 1   
                \  || s:countstr(p, '>') > 1
                \  || p[0] != '<'
                \  || p[len(p)-1] != '>'  
                    call s:Warning("Invalid link (".p.") in line(".lineCounter.")")
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
                call s:Warning("Key(".p.") links to a nonexistent key")
                call remove(patterns, j)
                let j -= 1
            endif
            let j += 1
        endfor

        if len(patterns) == 0
            call s:Warning("Key(".s:Dict[i][0].") has no valid patterns or links")
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
        let temp = "*.".ext
        if s:Dict[s:buffersChoicePos][2] == 1
            let s:TrackedExt = temp
            " Note: this has a very, very, very, small issue (is it even an
            " issue?) where if you're working with C++ files, and you switch to
            " buffers mode, and then edit a file of another type, like .c (which
            " should be in the C++ list), and then switch back to tracked mode,
            " you will lose the C++ association and have to go back to a C++
            " file before being able to search them.
            " This is so small of an issue that it's almost a non-issue, so I'm
            " not going to bother fixing it
        else
            let tempList = split(s:FilesToGrep)
            if index(tempList, temp) == -1
                let s:TrackedExt = temp
            endif
        endif
    endif
endfunction
"}}}
" SetWatchExtension {{{
function! s:SetWatchExtension()
    call s:CreateDict()
    augroup EasyGrepAutocommands
        au!
        autocmd BufEnter * call s:SetCurrentExtension()
    augroup END
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
    nmap <silent> <leader>vyi    :call <sid>ToggleIgnoreCase()<cr>
    nmap <silent> <leader>vyh    :call <sid>ToggleHidden()<cr>
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
        call s:Warning("No current word")
        return
    endif
    call s:DoGrep(currWord, a:add, a:whole, "")
endfunction
" }}}
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
        return 0
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

    if g:EasyGrepIgnoreCase
        if commandIsGrep
            let opts .= "-i "
        elseif commandIsFindstr
            let opts .= "/I "
        endif
    else
        if commandIsFindstr
            let opts .= "/i "
        endif
    endif

    if commandIsVimgrep
        call s:SaveVariable("ignorecase")
        let &ignorecase = g:EasyGrepIgnoreCase
    endif

    call s:BuildPatternList()

    if g:EasyGrepExtraWarnings
        if s:Dict[s:buffersChoicePos][2] == 1 && empty(s:FilesToGrep)
            call s:Warning("No saved buffers to explore")
            return
        endif

        if !g:EasyGrepRecursive
            if s:Dict[s:buffersChoicePos][2] != 1
                let fileDir = fnamemodify(bufname("."), ":p:h")
                if !empty(fileDir)
                    let cwd = getcwd()
                    if fileDir != cwd
                        call s:Warning("Warning: working directory [".cwd."] doesn't match the current file's directory [".fileDir."]")
                    endif
                endif
            endif

            " Don't evaluate if in recursive mode, this will take too long
            if !s:HasFilesThatMatch()
                call s:Warning("No files match against ".s:FilesToGrep)
                return
            endif
        endif
    endif

    let win = g:EasyGrepWindow != 0 ? "l" : ""

    " TODO: enumerate the error conditions of this call
    let failed = 0
    try
        let grepCommand = a:count.win.com.a:add." ".opts." ".s1.word.s2." ".s:FilesToGrep
        "echo grepCommand
        silent execute grepCommand
    catch
        if v:exception != 'E480'
            call s:WarnNoMatches(a:word)
            try
                " go to the last error list on no matches
                if g:EasyGrepWindow == 0
                    silent colder
                else
                    silent lolder
                endif
            catch
            endtry
        else
            call s:Error("FIXME: exception not caught ".v:exception)
        endif
        let failed = 1
    endtry

    call s:RestoreVariable("ignorecase")
    if failed
        return 0
    endif

    if s:HasMatches()
        if g:EasyGrepOpenWindowOnMatch
            if g:EasyGrepWindow == 0
                copen
            else
                lopen
            endif
            setlocal nofoldenable
        endif
    else
        call s:WarnNoMatches(a:word)
        return 0
    endif

    return 1
endfunction
" }}}
" GetSearchPatternFriendlyName {{{
function! s:GetSearchPatternFriendlyName()
    if s:Dict[s:buffersChoicePos][2] == 1
        return "*Buffers*"
    else
        return s:FilesToGrep
    endif
endfunction
" }}}
" WarnNoMatches {{{
function! s:WarnNoMatches(pattern)
    let str = "No matches for '".a:pattern."' in "
    let str .= s:GetSearchPatternFriendlyName()
    call s:Warning(str)
endfunction
" }}}
" ReplaceCurrentWord {{{
function! <sid>ReplaceCurrentWord(whole)
    let currWord=expand("<cword>")
    if empty(currWord)
        call s:Warning("No current word")
        return
    endif

    let r = input("Replace '".currWord."' with: ")
    if empty(r)
        return
    endif

    call s:DoReplace(currWord, r, a:whole)
endfunction
"}}}
" Replace {{{
function! s:Replace(whole, argv)
    let l = len(a:argv)
    let invalid = 0

    if l == 0
        let invalid = 1
    elseif l > 3 && a:argv[0] == '/'
        let ph = "EasyGrepPlaceholder"
        let temp = substitute(a:argv, '\\/', ph, "g")
        let l = len(temp)
        if temp[l-1] != '/'
            call s:Error("Missing trailing /")
            let invalid = 1
        elseif stridx(temp, '/', 1) == l-1
            call s:Error("Missing middle /")
            let invalid = 1
        elseif s:countstr(temp, '/') > 3
            call s:Error("Too many /'s, escape these if necessary")
            let invalid = 1
        else
            let argv = split(temp, '/')
            let i = 0
            while i < len(argv)
                let argv[i] = substitute(argv[i], ph, "\/", "g")
                let i += 1
            endwhile
        endif
    else
        let argv = split(a:argv)
        if len(argv) != 2
            call s:Error("Too many arguments")
            let invalid = 1
        endif
    endif

    if invalid
        call s:Error("usage: Replace /target/replacement/ --or-- Replace target replacement")
        return
    endif

    let target = argv[0]
    let replacement = argv[1]

    call s:DoReplace(target, replacement, a:whole)
endfunction
"}}}
" ReplaceUndo {{{
function! s:ReplaceUndo(bang)
    if !exists("s:actionList")
        call s:Error("No saved actions to undo")
        return
    endif

    " If either of these variables exists, that means the last command was
    " interrupted; give it another shot
    if !exists(s:GetSavedName("switchbuf")) && !exists(s:GetSavedName("autowriteall"))

        call s:SaveVariable("switchbuf")
        set switchbuf=useopen
        if g:EasyGrepReplaceWindowMode == 2
            call s:SaveVariable("autowriteall")
            set autowriteall
        else
            if g:EasyGrepReplaceWindowMode == 0
                set switchbuf+=usetab
            else
                set switchbuf+=split
            endif
        endif
    endif

    if g:EasyGrepWindow == 0
        call setqflist(s:LastErrorList)
        cfirst
    else
        call setloclist(0,s:LastErrorList)
        lfirst
    endif

    let bufList = s:GetVisibleBuffers()

    let i = 0
    let numItems = len(s:LastErrorList)
    let lastFile = -1

    let finished = 0
    while !finished
        try
            while i < numItems
                if s:actionList[i] == 1

                    if g:EasyGrepReplaceWindowMode == 0
                        let thisFile = s:LastErrorList[i].bufnr
                        if thisFile != lastFile
                            " only open a new tab when this window isn't already
                            " open
                            if index(bufList, thisFile) == -1
                                if lastFile != -1
                                    tabnew
                                endif
                                if g:EasyGrepWindow == 0
                                    copen
                                else
                                    lopen
                                endif
                                setlocal nofoldenable
                            endif
                        endif
                        let lastFile = thisFile
                    endif

                    if g:EasyGrepWindow == 0
                        execute "cc ".(i+1)
                    else
                        execute "ll ".(i+1)
                    endif

                    silent exe 's/'.s:LastReplacement.'/'.s:LastTarget.'/g'

                    let s:actionList[i] = 0
                endif

                let i += 1
            endwhile
            let finished = 1
        catch /^Vim(\a\+):E36:/
            call s:Warning("Ran out of room for more windows")
            let finished = confirm("Do you want to save all windows and continue?", "&Yes\n&No")-1
            if finished == 1
                call s:Warning("To continue, save unsaved windows, make some room (try :only) and run ReplaceUndo again")
                return
            else
                wall
                only
            endif
        catch /^Vim:Interrupt$/
            call s:Warning("Undo interrupted by user; state is not guaranteed")
            let finished = confirm("Are you sure you want to stop the undo?", "&Yes\n&No")-1
            let finished = !finished
        catch
            echo v:exception
            call s:Warning("Undo interrupted; state is not guaranteed")
            let finished = confirm("Do you want to continue undoing?", "&Yes\n&No")-1
        endtry
    endwhile

    call s:RestoreVariable("switchbuf")
    call s:RestoreVariable("autowriteall")

    unlet s:actionList
    unlet s:LastErrorList
endfunction
"}}}
" DoReplace {{{
function! s:DoReplace(target, replacement, whole)

    let target = escape(a:target, '/')
    if !s:DoGrep(target, "", a:whole, "")
        return
    endif

    let replacement = escape(a:replacement, '/')

    " TODO: is a deepcopy needed here?
    let s:LastErrorList = deepcopy(s:GetErrorList())
    let numMatches = len(s:LastErrorList)
    let s:actionList = repeat([0], numMatches)

    let s:LastTarget = a:target
    let s:LastReplacement = a:replacement


    call s:SaveVariable("switchbuf")
    set switchbuf=useopen
    if g:EasyGrepReplaceWindowMode == 2
        call s:SaveVariable("autowriteall")
        set autowriteall
    else
        if g:EasyGrepReplaceWindowMode == 0
            set switchbuf+=usetab
        else
            set switchbuf+=split
        endif
    endif

    let opts = ""
    if !g:EasyGrepEveryMatch
        let opts .= "g"
    endif

    let bufList = s:GetVisibleBuffers()

    " this highlights the match; it seems to be a simpler solution
    " than matchadd()
    if g:EasyGrepWindow == 0
        cfirst
    else
        lfirst
    endif
    silent exe "s/".target."\\c//n"

    call s:SaveVariable("cursorline")
    set cursorline

    " TODO: figure out how to get the individual target at each step highlighted
    let finished = 0
    let lastFile = -1
    let doAll = 0
    let i = 0
    while i < numMatches && !finished
        try
            let pendingQuit = 0
            let doit = 1

            let thisFile = s:LastErrorList[i].bufnr
            if thisFile != lastFile
                call s:RestoreVariable("cursorline", "no")
                if g:EasyGrepReplaceWindowMode == 0
                    " only open a new tab when the window doesn't already exist
                    if index(bufList, thisFile) == -1
                        if lastFile != -1
                            tabnew
                        endif
                        if g:EasyGrepWindow == 0
                            copen
                        else
                            lopen
                        endif
                        setlocal nofoldenable
                    endif
                endif
                if doAll && g:EasyGrepReplaceAllPerFile
                    let doAll = 0
                endif
            endif

            if g:EasyGrepWindow == 0
                execute "cc ".(i+1)
            else
                execute "ll ".(i+1)
            endif

            if thisFile != lastFile
                set cursorline
            endif
            let lastFile = thisFile

            if foldclosed(".") != -1
                foldopen!
            endif

            if !doAll

                redraw
                echohl Type | echo "replace with ".a:replacement." (y/n/a/q/l/^E/^Y)?"| echohl None
                let ret = getchar()

                if ret == 5
                    " FIXME: the normal command doesn't work
                    normal "\<c-e>"
                    continue
                elseif ret == 25
                    normal "\<c-y>"
                    continue
                else
                    let ret = nr2char(ret)

                    if ret == '<cr>'
                        continue
                    elseif ret == 'y'
                        " doit
                    elseif ret == 'n'
                        let doit = 0
                    elseif ret == 'a'
                        " doit
                        let doAll = 1
                    elseif ret == 'q'
                        break
                    elseif ret == 'l'
                        let pendingQuit = 1
                    else
                        continue
                    endif
                endif
            endif

            if doit
                exe 's/'.target.'/'.replacement.'/'.opts
                let s:actionList[i] = doit
            endif

            if pendingQuit
                break
            endif

            let i += 1

        catch /^Vim(\a\+):E36:/
            call s:Warning("Ran out of room for more windows")
            let finished = confirm("Do you want to save all windows and continue?", "&Yes\n&No")-1
            if finished == 1
                call s:Warning("To continue, save unsaved windows, make some room (try :only) and run Replace again")
            else
                wall
                only
            endif
        catch /^Vim:Interrupt$/
            call s:Warning("Replace interrupted by user")
            let finished = confirm("Are you sure you want to stop the replace?", "&Yes\n&No")-1
            let finished = !finished
        catch
            echo v:exception
            call s:Warning("Replace interrupted")
            let finished = confirm("Do you want to continue replace?", "&Yes\n&No")-1
        endtry
    endwhile


    call s:RestoreVariable("switchbuf")
    call s:RestoreVariable("autowriteall")
    call s:RestoreVariable("cursorline")
endfunction
"}}}
" }}}

" Commands {{{
command! -count -bang -nargs=1 Grep :call s:GrepInput( <f-args> , "", "<bang>", "<count>")
command! -count -bang -nargs=1 GrepAdd :call s:GrepInput( <f-args>, "add", "<bang>", "<count>")
command! -nargs=? GrepOptions :call <sid>GrepOptions( <f-args> )

command! -bang -nargs=+ Replace :call s:Replace("<bang>", <q-args>)
command! -bang ReplaceUndo :call s:ReplaceUndo("<bang>")
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
if !hasmapto("<plug>EgMapReplaceCurrentWordr")
    map <silent> <Leader>vr <plug>EgMapReplaceCurrentWordr
endif
if !hasmapto("<plug>EgMapReplaceCurrentWordR")
    map <silent> <Leader>vR <plug>EgMapReplaceCurrentWordR
endif

nmap <silent> <unique> <script> <plug>EgMapGrepOptions      :call <sid>GrepOptions()<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWordv :call <sid>GrepCurrentWord("", 0)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWordV :call <sid>GrepCurrentWord("", 1)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWorda :call <sid>GrepCurrentWord("add", 0)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWordA :call <sid>GrepCurrentWord("add", 1)<CR>
nmap <silent> <unique> <script> <plug>EgMapReplaceCurrentWordr :call <sid>ReplaceCurrentWord(0)<CR>
nmap <silent> <unique> <script> <plug>EgMapReplaceCurrentWordR :call <sid>ReplaceCurrentWord(1)<CR>

if !g:EasyGrepNoDirectMappings
    call s:CreateDirectMappings()
endif
"}}}


