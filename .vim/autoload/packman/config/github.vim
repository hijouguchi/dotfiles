" GitHub 向けの config 生成
let s:save_cpo = &cpo
set cpo&vim

" github リポジトリを packadd する
function! packman#config#github#load_impl() dict "{{{
  if !s:checkouted(self)
    call s:checkout(self)
  end

  execute 'packadd ' . substitute(self.cfg.repo, '^.*\/', '', '')
endfunction "}}}

" github リポジトリを update する
function! packman#config#github#update_impl() dict "{{{
  let dir = self.directory()
  call packman#mics#echo('updating ' . self.cfg.repo . '...')
  call system('cd ' . dir . ' && git pull')
endfunction "}}}

" オブジェクトを作る
" 引数は未定
function! packman#config#github#new(repo, ...) abort "{{{
  let obj          = call('packman#config#new', a:000)
  let obj.cfg.repo = a:repo

  " クラスメソッドを登録する
  let flist = [
        \ 'load_impl',
        \ 'update_impl'
        \ ]

  for f in flist
    let obj[f] = function('packman#config#github#' . f)
  endfor

  return obj
endfunction "}}}

" インストール先のディレクト名を返す
function! s:directory(obj) abort "{{{
  return g:packman_default_directory . '/'
        \ . substitute(a:obj.cfg.repo, '^.*\/', '', '')
endfunction "}}}

" ディレクトリがあるかを確認する
function! s:checkouted(obj) abort "{{{
  let dir = s:directory(a:obj)
  return isdirectory(dir)
endfunction "}}}

" github リポジトリを clone する
function! s:checkout(obj) abort "{{{
  let dir = s:directory(a:obj)
  let url  = 'https://github.com/' . a:obj.cfg.repo

  call packman#mics#echo('installing ' . a:obj.cfg.repo . '...')
  call system('mkdir -p '.g:packman_default_directory)
  call system('git clone --depth 1 --single-branch --recursive ' . url . ' ' . dir)
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
