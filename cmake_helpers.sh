# Created by Basvas j.k.j <basvas@seznam.cz>
# https://github.com/basvas-jkj/cpp_modules
# Unlicensed <https://unlicense.org>

alias ctest_plain="env ctest"
alias cpack_plain="env cpack"

cinit()
{
	if [ $# -eq 0 ]
	then
		cmake --list-presets
	else
		cmake --preset "$@"
	fi
}
cbuild()
{
	if [ $# -eq 0 ]
	then
		cmake --build --list-presets
	else
		cmake --build --preset "$@"
	fi
}
cwork()
{
	if [ $# -eq 0 ]
	then
		cmake --workflow --list-presets
	else
		cmake --workflow --preset "$@"
	fi
}
ctest()
{
	if  [ $# -eq 0 ]
	then
		ctest_plain --list-presets
	else
		ctest_plain --preset "$@"
	fi
}
cpack()
{
	if  [ $# -eq 0 ]
	then
		cpack_plain --list-presets
	else
		cpack_plain --preset "$@"
	fi
}

_cinit()
{
  local presets=($(cmake --list-presets 2>/dev/null | grep -o '^  ".*"' | sed -e 's/^  "//' -e 's/"$//'))
  COMPREPLY=( $(compgen -W "${presets[*]}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
_cbuild()
{
  local presets=($(cmake --build --list-presets 2>/dev/null | grep -o '^  ".*"' | sed -e 's/^  "//' -e 's/"$//'))
  COMPREPLY=( $(compgen -W "${presets[*]}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
_cwork()
{
  local presets=($(cmake --workflow --list-presets 2>/dev/null | grep -o '^  ".*"' | sed -e 's/^  "//' -e 's/"$//'))
  COMPREPLY=( $(compgen -W "${presets[*]}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
_ctest()
{
  local presets=($(ctest_plain --list-presets 2>/dev/null | grep -o '^  ".*"' | sed -e 's/^  "//' -e 's/"$//'))
  COMPREPLY=( $(compgen -W "${presets[*]}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
_cpack()
{
  local presets=($(cpack_plain --list-presets 2>/dev/null | grep -o '^  ".*"' | sed -e 's/^  "//' -e 's/"$//'))
  COMPREPLY=( $(compgen -W "${presets[*]}" -- "${COMP_WORDS[COMP_CWORD]}") )
}

complete -F _cinit cinit
complete -F _cbuild cbuild
complete -F _cwork cwork
complete -F _ctest ctest
complete -F _cpack cpack
complete -F _cinit crun