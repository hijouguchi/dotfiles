call packman#config#github#new( 'vim-scripts/vcscommand.vim')
      \.add_hook_commands(
      \  'VCSCommit', 'VCSDiff',   'VCSLog',     'VCSRevert',
      \  'VCSStatus', 'VCSUpdate', 'VCSVimDiff', 'VCSBlame',
      \  'VCSAdd'
      \)
