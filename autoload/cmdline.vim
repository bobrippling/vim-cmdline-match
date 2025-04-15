function! s:get_re(cmd, capture_before)
	if getcmdtype() != ':'
		return 0
	endif

	let range1 = "%(%(-?[0-9%$]*|'.) *)?"
	let range = range1 . "%(," . range1 . ")?"

	let modifiers = '%(%(hid%[e]|keepa%[lt]|tab|vert%[ical]|lefta%[bove]|abo%[veleft]|rightb%[elow]|bel%[owright]|to%[pleft]|bo%[tright]|' . range . ')\s+)*'

	if a:capture_before
		let open = '('
		let close = ')'
	else
		let open = ''
		let close = ''
	endif

	" TODO: getcmdpos for better matching
	return '\v' . open . '%(^|\|)[: \t]*' . modifiers . range . close . '%(' . a:cmd . ')'
endfunction

function! cmdline#matching(re)
	let re = s:get_re(a:re, 0)
	return matchlist(getcmdline(), re)
endfunction

" split `cmd` into three parts:
" pre  (e.g. `bot`)
" cmd  (e.g. `sp`)
" post (e.g. `file.txt`)
function! cmdline#split(re, ...)
	if a:0 > 1
		throw "cmdline#split: too many args"
	endif

	let cmd = a:0 > 0 ? a:1 : getcmdline()

	let re = s:get_re(a:re . '(.*)', 1)

	if cmd !~ re
		return []
	endif

	" \1: pre
	" \2...: a:re
	" \3: post
	return split(cmd, '\ze' . re)
endfunction

function! cmdline#matches_cmd(re)
	let re = s:get_re(a:re, 0)
	return getcmdline() =~ re
endfunction
