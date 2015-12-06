if [[ `uname` ==  'Linux' ]]
then
    prodcertstatus -q || prodaccess
    fpath=($(realpath /google/src/files/head/depot/google3/devtools/blaze/scripts/zsh_completion) $fpath)
fi
