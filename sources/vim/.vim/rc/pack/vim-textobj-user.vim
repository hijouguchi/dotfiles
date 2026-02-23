call packman#config#github#new('kana/vim-textobj-user.git')
      \.set_lazy(v:true)
      \.add_depends(
      \  packman#config#github#new('sgur/vim-textobj-parameter.git')
      \)

