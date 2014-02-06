" typed-clojure.vim 
" Maintainer: Ambrose Bonnaire-Sergeant <http://github.com/frenchy64>

if exists("g:loaded_typed_clojure") || v:version < 700 || &cp
  finish
endif
let g:loaded_typed_clojure = 1


function! s:currentqfline() abort
  lopen
  let l = line('.')
  "revert to previous position
  wincmd P
  return l
endfunction

function! s:get_display_qf_text_at(n) abort
  let q = getloclist(0)
  let txt = get(q, a:n - 1).text
  return txt
endfunction

function! typed_clojure#display_current_location_text() abort
  let txt = s:get_display_qf_text_at(s:currentqfline())
  pedit :
  wincmd P
  call append(line('$'), split(txt, "\n"))
  wincmd P
endfunction

function! s:tc_qfmassage(errormap) abort
  let entry = {}
  let entry.text = a:errormap.message
  let entry.lnum = a:errormap.line
  let entry.col = a:errormap.column
  let entry.filename = fireplace#findresource(a:errormap.source)
  return entry
endfunction

function! s:tc_quickfix_for(errors) abort
  return map(copy(a:errors), 's:tc_qfmassage(v:val)')
endfunction

function! s:checknsop() abort
  let cmd =
        \ '(let [{:keys [delayed-errors]} (clojure.core.typed/check-ns-info)]'.
        \ '  (if (seq delayed-errors)'.
        \ '    [:errors'.
        \ '     (for [^Exception e delayed-errors]'.
        \ '      (let [{:keys [env] :as data} (ex-data e)]'.
        \ '        {:message (.getMessage e) :line (:line env)'.
        \ '         :column (:column env) :form (if (contains? data :form) (str (:form data)) 0)'.
        \ '         :source (:source env) :ns (-> env :ns :name str)}))]'.
        \ '    [:ok []]))'
  let [status, r] = fireplace#evalparse(cmd)
  lclose
  if status ==# 'ok'
    echo ':ok'
  else
    echo 'Found type errors (view with :lopen)'
    call setloclist(0, s:tc_quickfix_for(r))
    lopen
  endif
endfunction

function! typed_clojure#type_check_ns() abort
  call s:checknsop()
endfunction

nnoremap <silent> <Plug>TypedClojureCheckNs :<C-U>call <SID>checknsop()<CR>

function! s:setup_eval() abort
   nmap <buffer> ctn <Plug>TypedClojureCheckNs
endfunction
