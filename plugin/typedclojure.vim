" typedclojure.vim 
" Maintainer: Ambrose Bonnaire-Sergeant <http://github.com/frenchy64>

if exists("g:loaded_typedclojure") || v:version < 700 || &cp
  finish
endif
let g:loaded_typedclojure = 1

"function! s:currentqfline() abort
"  lopen
"  let l = line('.')
"  "revert to previous position
"  wincmd P
"  return l
"endfunction

let s:tc_ns = 'vim.typedclojure'
let s:tc_mapping = 'vim.typedclojure/file-mapping'

function! s:init_internal_env() abort
  let cmd = 
        \ "(clojure.core/when-not (clojure.core/resolve '".s:tc_mapping.')'.
        \ "  (clojure.core/create-ns '".s:tc_ns.')'.
        \ "  (clojure.core/intern '".s:tc_ns. 
        \ "                       (clojure.core/symbol (clojure.core/name '".s:tc_mapping.'))'. 
        \ '                       (clojure.core/atom {} :validator clojure.core/map?)))'
  let res = fireplace#evalparse(cmd)
endfunction

function! s:get_display_qf_text_at(n) abort
  let q = getloclist(0)
  let txt = get(q, a:n - 1).text
  return txt
endfunction

function! typedclojure#display_current_location_text() abort
  if &buftype ==# 'quickfix'
    let txt = s:get_display_qf_text_at(line('.'))
    pedit! :
    wincmd P
    if &previewwindow
      nnoremap <buffer> <silent> q    :<C-U>bdelete<CR>
      normal gg
      normal dGG
      call append(line('.'), split(txt, "\n"))
      wincmd p " back to quickfix
    endif
  endif
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
  call s:init_internal_env()
  let cmd =
        \ '(clojure.core/let'.
        \ '  [{:keys [delayed-errors file-mapping]} (clojure.core.typed/check-ns-info clojure.core/*ns* :file-mapping true)]'.
        \ '  (clojure.core/when file-mapping'.
        \ '    (clojure.core/reset! '.s:tc_mapping.' file-mapping))'.
        \ '  (if (clojure.core/seq delayed-errors)'.
        \ '    [:errors '.
        \ '     (clojure.core/for [^java.lang.Exception e delayed-errors]'.
        \ '      (clojure.core/let [{:keys [env] :as data} (clojure.core/ex-data e)]'.
        \ '        {:message (.getMessage e)'.
        \ '         :line (:line env)'.
        \ '         :column (:column env)'.
        \ '         :form (if (clojure.core/contains? data :form) (clojure.core/str (:form data)) 0)'.
        \ '         :source (or (:file env) '.
        \ '                     (:source env)'.
        \ '                     (clojure.core/when-let [ns (-> env :ns :name str)]'.
        \ '                       (clojure.core/str (clojure.core/apply clojure.core/str (clojure.core/replace {\. \/ \- \_} ns)) ".clj")))'.
        \ '         :ns (-> env :ns :name str)}))]'.
        \ '    [:ok []]))'
  let [status, r] = fireplace#evalparse(cmd)
  lclose
  if status ==# 'ok'
    echo ':ok'
  else
    echo 'Found type errors (view with :lopen)'
    call setloclist(0, s:tc_quickfix_for(r))
    lopen
    nnoremap <silent> <Plug>TypedClojureShowQFError :<C-U>call typedclojure#display_current_location_text()<CR>
    nmap <buffer> ce <Plug>TypedClojureShowQFError 
  endif
endfunction

"from fireplace.vim
function! s:str(string) abort
  return '"' . escape(a:string, '"\') . '"'
endfunction

function s:type_loc() abort
  call s:init_internal_env()
  let l = line('.')
  let c = col('.')
  let cmd = 
        \ '(clojure.core/let [p '.s:str(tr(fireplace#ns(), '-.', '_/').'.clj').']'.
        \ '  (@'.s:tc_mapping.' {:file p :line '.l.' :column '.c.'}))'
  let res = fireplace#evalparse(cmd)
  return res
endfunction!

function! typedclojure#cursor_type() abort
  call s:type_loc()
endfunction

function! typedclojure#type_check_ns() abort
  call s:checknsop()
endfunction

function! s:setup_check() abort
   command! CheckNs exe s:checknsop()
   nnoremap <silent> <Plug>TypedClojureCheckNs :<C-U>call <SID>checknsop()<CR>
   nnoremap <silent> <Plug>TypedClojureCursorType :<C-U>call <SID>type_loc()<CR>
   nmap <buffer> ctn <Plug>TypedClojureCheckNs
   nmap <buffer> T <Plug>TypedClojureCursorType
endfunction

augroup TypedClojureCheck
  autocmd!
  autocmd FileType clojure :call s:setup_check()
augroup END
