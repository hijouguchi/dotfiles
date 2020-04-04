if exists("g:loaded_highword")
  finish
endif
let g:loaded_highword = 1

let s:save_cpo = &cpo
set cpo&vim

" 欲しい機能一覧
" 1. 単語に色を付ける機能
"   1. コマンドラインで単語を指定
"   2. カーソル位置の単語
"   3. カレントだけでなくすべてのバッファ(window, tab も含む) に反映させる
" 2. 色を付けた単語を削除する機能
"   1. コマンドラインで単語を指定
"      削除する単語は補完できるように
"   2. カーソル位置の単語
"   3. カレントだけでなくすべてのバッファ(window, tab も含む) に反映させる
" 3. 色をつけた単語の一覧を表示
" 4. 登録した単語をすべて削除
"   1. 削除したらすべてのバッファに反映させる
" 5. * を押すと
"   1. 色がついていない単語 -> 色をつける
"   2. 色がついてる単語は   -> 次にジャンプする
" 6. # を押すと
"   1. 色を消す
" 7. 色つける個数は任意の増やしたり減らしたりできるようにする

" 実装
" 1. getmatches() に登録されている情報を使って

nnoremap <silent> * :call highword#add_from_normal()<CR>
nnoremap <silent> # :call highword#remove_from_normal()<CR>

vnoremap <silent> * :call highword#add_from_visual()<CR>
vnoremap <silent> # :call highword#remove_from_visual()<CR>

command! HighWordClear  call highword#clear()
command! HighWordList   call highword#show_list()
command! -nargs=* -complete=customlist,highword#word_complete HighWordRemove call highword#remove_from_command(<f-args>)
command! -nargs=* HighWordAdd call highword#add_from_command(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
