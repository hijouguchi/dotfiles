" コンフィグの作成
let s:save_cpo = &cpo
set cpo&vim

let s:object = #{
      \   cfg : #{
      \     loaded   : v:false,
      \     depended : v:false,
      \     repo     : ''
      \   },
      \   load_impl   : function('packman#mics#nop'),
      \   update_impl : function('packman#mics#nop'),
      \   pre_load    : function('packman#mics#nop'),
      \   post_load   : function('packman#mics#nop')
      \ }

" 遅延読み込み設定
" @param [in] true 遅延読み込みを有効にする
" @param [in] true 遅延読み込みを無効にする
function! s:object.set_lazy(flag) abort "{{{
  let self.cfg.lazy = a:flag

  return self
endfunction "}}}

" obj.cfg.loaded を返す
function! s:object.loaded() abort "{{{
  return get(self.cfg, 'loaded', v:false)
endfunction "}}}

" obj.cfg.depended を返す
function! s:object.depended() abort "{{{
  return get(self.cfg, 'depended', v:false)
endfunction "}}}

" obj.cfg.repo  を返す
function! s:object.repo() abort "{{{
  return get(self.cfg, 'repo', '')
endfunction "}}}

" パッケージをロードする
function! s:object.load() abort "{{{
  if self.loaded()
    return
  endif

  " hook をすべて削除
  call packman#hook#command#clear(self)
  call packman#hook#keymap#clear (self)
  call packman#hook#event#clear  (self)

  " 自分をロードする
  call self.pre_load()
  call self.load_impl()
  call self.post_load()

  " depends されたオブジェクトをすべてロードする
  if has_key(self.cfg, 'depends')
    for obj in self.cfg.depends
      call obj.load()
    endfor
  endif

  let self.cfg.loaded = v:true
endfunction "}}}

" パッケージのロードを試みる
" lazy フラグが付いてたらロードしないでフックを登録する
function! s:object.try_load() abort "{{{

  " depended 属性がついてたらここではロードしない
  if get(self.cfg, 'depended', v:false)
    return
  endif

  let lazy = packman#hook#command#set(self)
  let lazy = packman#hook#keymap#set (self) || lazy
  let lazy = packman#hook#event#set  (self) || lazy
  let lazy = packman#hook#timer#set  (self) || lazy

  if !lazy
    call self.load()
  endif
endfunction "}}}

" パッケージのアップデートを試みる
function! s:object.update() abort "{{{
  call self.update_impl()
endfunction "}}}

" obj.cfg.depands を追加する
" @param [in] depends する obj
function! s:object.add_depends(...) abort "{{{
  if !has_key(self.cfg, 'depends')
    let self.cfg.depends = []
  endif

  " 関連付けしたオブジェクトは depended 属性をつける
  for obj in a:000
    let obj.cfg.depended = v:true
  endfor

  call extend(self.cfg.depends, a:000)

  return self
endfunction "}}}

" obj.cfg.hook_keymaps を追加する
" @param [in] keymap
function! s:object.add_hook_keymaps(...) abort "{{{
  if !has_key(self.cfg, 'hook_keymaps')
    let self.cfg.hook_keymaps = []
  endif

  call extend(self.cfg.hook_keymaps, a:000)

  return self
endfunction "}}}

" obj.cfg.hook_commands を追加する
" @param [in] commands
function! s:object.add_hook_commands(...) abort "{{{
  if !has_key(self.cfg, 'hook_commands')
    let self.cfg.hook_commands = []
  endif

  call extend(self.cfg.hook_commands, a:000)

  return self
endfunction "}}}

" obj.cfg.hook_events を追加する
" @param [in] commands
function! s:object.add_hook_events(...) abort "{{{
  if !has_key(self.cfg, 'hook_events')
    let self.cfg.hook_events = []
  endif

  call extend(self.cfg.hook_events, a:000)

  return self
endfunction "}}}

" オブジェクトを作る
" 引数は未定
function! packman#config#new(...) abort "{{{
  let obj     = deepcopy(s:object)
  let obj.id  = packman#push(obj)
  return obj
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
