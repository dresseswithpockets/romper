odin build test.odin -file -build-mode:shared -out:libtest.so -debug || exit $?;
$1 -Wall -Werror -o test_dlopen main.c -g || exit $?;
$1 -Wall -Werror -o test_linked main.c -ltest -L. -DTEST_LINKED -g || exit $?;

printf '\n[mode: dlopen]\n'
LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH} ./test_dlopen || exit $?;

printf '\n[mode: linked]\n'
LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH} ./test_linked || exit $?;
