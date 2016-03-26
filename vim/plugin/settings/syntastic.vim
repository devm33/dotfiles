" Syntastic settings
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '!'
let g:syntastic_check_on_open = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_always_populate_loc_list = 0
let g:syntastic_python_checkers=['flake8', 'pyflakes']
let g:syntastic_python_flake8_exec = 'python2.7'
let g:syntastic_python_flake8_args='--ignore=E501,E401,E302,E261,E128,E265'
let g:syntastic_python_python_exec = 'python2.7'
let g:syntastic_html_checkers=[]
let g:syntastic_java_checkers = ['checkstyle']
