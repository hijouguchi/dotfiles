if !exists("g:loaded_highword")
  runtime! plugin/highword.vim
endif

let s:save_cpo = &cpo
set cpo&vim


" normal mode で * を押したとき、feedkeys する値
" すでに HighWord に登録されていた時の挙動
if !exists('g:highword_match_command')
  let g:highword_match_command = 'nzvzz'
endif

" normal mode で * を押したとき、feedkeys する値
" 新たに HighWord に登録した時の挙動
if !exists('g:highword_not_match_command')
  let g:highword_not_match_command = ''
endif

" HighWord の highlight 設定情報
if !exists('g:highword_highlight_config') "{{{
  let g:highword_highlight_config = [
        \ #{ctermfg:'black', ctermbg:'88',  guifg:'black', guibg:'#660000'},
        \ #{ctermfg:'black', ctermbg:'94',  guifg:'black', guibg:'#663300'},
        \ #{ctermfg:'black', ctermbg:'100', guifg:'black', guibg:'#666600'},
        \ #{ctermfg:'black', ctermbg:'64',  guifg:'black', guibg:'#336600'},
        \ #{ctermfg:'black', ctermbg:'28',  guifg:'black', guibg:'#006600'},
        \ #{ctermfg:'black', ctermbg:'29',  guifg:'black', guibg:'#006633'},
        \ #{ctermfg:'black', ctermbg:'30',  guifg:'black', guibg:'#006666'},
        \ #{ctermfg:'black', ctermbg:'24',  guifg:'black', guibg:'#003366'},
        \ #{ctermfg:'black', ctermbg:'18',  guifg:'black', guibg:'#000066'},
        \ #{ctermfg:'black', ctermbg:'54',  guifg:'black', guibg:'#330066'},
        \ #{ctermfg:'black', ctermbg:'90',  guifg:'black', guibg:'#660066'},
        \ #{ctermfg:'black', ctermbg:'98',  guifg:'black', guibg:'#660033'}
        \ ]
endif "}}}

let s:highword_keyword = 'HighWord'
let s:highword_regexp  = '^' . s:highword_keyword . '\d\+$'

" HighWord を初期化する
" すでに準備できていたら何もしない
function! highword#try_init() abort "{{{
  if exists('s:autocmd_loaded')
    return
  endif
  let s:autocmd_loaded = 1

  call s:init_colorscheme()
  call s:init_autocmd()
endfunction "}}}

" CommandLine 上からパターンを登録する
function! highword#add_from_command(word) abort "{{{
  call s:add_tabwindo(a:word)
endfunction "}}}

" normal mode でカーソル位置の文字列を検索する
"
" @detail
"   カーソル位置の文字列を検索する
"   すでに登録されていれば g:highword_match_command を feedkey するし、
"   されていなければ g:highword_match_command を feedkey する
function! highword#add_from_normal() abort "{{{
    let word = expand('<cword>')
    let mat  = '\<' . word . '\>\C'

    let feedkeys = [
          \   g:highword_not_match_command,
          \   g:highword_match_command
          \ ]

    let fk = feedkeys[s:add_tabwindo(mat)]

    if fk != ''
      call feedkeys(fk, 'n')
    endif
endfunction "}}}

" virual mode で選択範囲の文字列を検索する
" @detail
"   文字単位のビジュアルモードでしか対応しない
"   行単位、矩形単位の時は単に無視する
function! highword#add_from_visual() range "{{{
  " visual mode で選択された文字列を取得する
  " See Also: https://nanasi.jp/articles/code/command/command-range.html
  let tmp = @@
  silent normal gvy
  let selected = @@
  let @@ = tmp

  " 複数行になっていたら文字単位じゃないと判断して無視する
  if selected =~ '\n'
    return
  endif

  let mat = '\<' . selected . '\>\C'
  call s:add_tabwindo(mat)
endfunction "}}}

" CommandLine 上からパターンを削除する
function! highword#remove_from_command(word) abort "{{{
  call s:remove_tabwindo(a:word)
endfunction "}}}

" normal mode でカーソル位置の文字列を削除する
"
" @detail
"   カーソル位置の文字列を HighWord のカラーから削除する
function! highword#remove_from_normal() abort "{{{
  let word = expand('<cword>')
  let mat  = '\<' . word . '\>\C'
  call s:remove_tabwindo(mat)
endfunction "}}}

" virual mode で選択範囲の文字列を削除する
" @detail
"   文字単位のビジュアルモードでしか対応しない
"   行単位、矩形単位の時は単に無視する
function! highword#remove_from_visual() range "{{{
  " visual mode で選択された文字列を取得する
  " See Also: https://nanasi.jp/articles/code/command/command-range.html
  let tmp = @@
  silent normal gvy
  let selected = @@
  let @@ = tmp

  " 複数行になっていたら文字単位じゃないと判断して無視する
  if selected =~ '\n'
    return
  endif

  let mat = '\<' . selected . '\>\C'
  call s:remove_tabwindo(mat)
endfunction "}}}

" すべての HighWord を削除する
function! highword#clear() abort "{{{
  let save = s:get_tabwinnr()
  tabdo windo call s:remove()
  call s:set_tabwinnr(save)
endfunction "}}}

" カレントバッファで HighWord に登録されている
" 検索パターンの一覧を echo する
function! highword#show_list() abort "{{{
  let list = s:get_highword_patterns()

  for l in s:get_highword_patterns()
    echo '"' . l . '"'
  endfor
endfunction "}}}

" カレントバッファに登録されている HighWord 一覧を
" s:match_pattern_list に保存する
function! highword#match_push() abort "{{{
  let s:match_pattern_list = s:find_patterns()
endfunction "}}}

" カレントバッファに s:match_pattern_list に登録されている
" HighWord 一覧を登録する
function! highword#match_pop() abort "{{{
  if !exists('s:match_pattern_list')
    return
  endif

  let cur_patterns = s:get_highword_patterns()

  for mat in s:match_pattern_list
    " すでに登録されている pattern は無視する
    if count(cur_patterns , mat.pattern) == 0
      call matchadd(mat.group, mat.pattern)
    endif
  endfor

  unlet s:match_pattern_list
endfunction "}}}


" HighWordDelete 関数の補完一覧
"
" @detail
"   HighWord に登録されている pattern の一覧を取得する
function! highword#word_complete(arglead, cmdline, cursorpos) abort "{{{
  return s:get_highword_patterns()
endfunction "}}}

" getmatches() から HighWord の group を探しつつ
" 引数にあるパターンに引っかかるものを返す
" 引数が空の時は group だけで検索
" @param [in] 検索する pattern
"
" @return getmatches() の結果から、
" group が HighWord で、pattern が引数で指定したもの
function! s:find_patterns(...) abort "{{{
  let ma = getmatches()
          \ ->filter({_, v -> v.group =~ s:highword_regexp })

  if a:0 > 0
    let tmp = []

    for e in a:000
      let tmp += copy(ma)
            \ ->filter({_, v -> e == v.pattern})
    endfor

    let ma = tmp
  endif

  return ma
endfunction "}}}

" HighWord に登録されている pattern の一覧を取得する
function! s:get_highword_patterns() abort "{{{
  return copy(s:find_patterns())->map({_, v -> v.pattern})
endfunction "}}}

" 次に使用する HighWord の番号を選ぶ (選んだハイライトの名前を返す)
" @return 以下に該当した HighWord のハイライト名
" 1. 最も使用個数が少ない番号
" 2. (1) のうち番号が若い
function! s:get_highword() abort "{{{
  " getmatches() から group だけ取り出した配列
  let matches = map(getmatches(), {_, v -> v.group} )

  let str = s:highword_keyword . 0
  let cnt = matches->count(str)

  " 0 から検索だと無駄だけど、まぁいいや
  for i in len(g:highword_highlight_config)->range()
    let targ = s:highword_keyword . i
    let tmp  = matches->count(targ)

    if tmp < cnt
      let cnt = tmp
      let str = targ
    endif
  endfor

  return str
endfunction "}}}

" 指定されたパターンを削除する
" @param [in] 削除したいパターン名
"             引数なしならすべて削除する
function! s:remove(...) abort "{{{
  let ma = call('s:find_patterns', a:000)

  for m in ma
    call matchdelete(m.id)
  endfor
endfunction "}}}

" 指定されたパターンをすべての window, tab に登録する
"
" @detail
"   パターンが登録されていない場合は、すべての window, tab に
"   パターンを matchadd() する
"
" @param [in] 登録したいパターン
"
" @return true  すでにパターンが登録されている
" @return false パターンが登録されていない
function! s:add_tabwindo(mat) abort "{{{
  " ひとまずヒストリには登録する
  call s:update_last_history(a:mat)

  let ma  = s:find_patterns(a:mat)
  if !empty(ma) " すでに登録されている
    return v:true
  endif

  " 登録する highlight は先に決めておく
  let hlname = s:get_highword()
  call highword#try_init()

  let save = s:get_tabwinnr()
  tabdo windo call matchadd(hlname, a:mat)
  call s:set_tabwinnr(save)

  return v:false
endfunction "}}}

" 指定されたパターンをすべての window, tab で削除する
"
" @param [in] 削除したいパターン
function! s:remove_tabwindo(mat) abort "{{{
  let save = s:get_tabwinnr()
  tabdo windo call s:remove(a:mat)
  call s:set_tabwinnr(save)
endfunction "}}}

" tabpagenr, winnr を返す
"
" @return [winnr(), tabpagenr()]
function! s:get_tabwinnr() abort "{{{
  return [winnr(), tabpagenr()]
endfunction "}}}

" tabpagenr, winnr を更新する
"
" @param [in] s:get_tabwinnr() の返却値そのもの
function! s:set_tabwinnr(arg) abort "{{{
  execute a:arg[1] . 'tabnext'
  execute a:arg[0] . 'wincmd w'
endfunction "}}}

" g:highword_highlight_config から colorscheme を作って登録する
function! s:init_colorscheme() abort "{{{
  if hlexists(s:highword_keyword . 0)
    return
  endif

  " config を highlight コマンドに作り変えて実行
  for i in len(g:highword_highlight_config)->range()
    let e    = g:highword_highlight_config[i]
    let cmd  = 'highlight ' . s:highword_keyword . i . ' '
    let cmd .= e->keys()
          \ ->map({_, k -> k . '=' . e[k]})
          \ ->join()
    execute cmd
  endfor
endfunction "}}}

" autocmd を設定する
function! s:init_autocmd() abort "{{{
  augroup HighWord
    autocmd!
    autocmd BufWinEnter,ColorScheme * call highword#match_pop()
    autocmd WinEnter                * call highword#match_pop()
    autocmd WinLeave                * call highword#match_push()
  augroup END
endfunction "}}}

" 最終検索パターンに登録する
" @param [in] word 登録する文字列
function! s:update_last_history(word) abort "{{{
  let @/ = a:word
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
