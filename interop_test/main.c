#include <stdio.h>
#include <stdlib.h>

typedef struct callback_struct {
  void (*callback)();
} callback_struct;

typedef struct test_funcs_struct {
  void (*imported_print)(const char *);
  void (*set_callback)(callback_struct);
} test_funcs_struct;

callback_struct _callback_inst = {NULL};

void execute();
void print_func(const char *msg);
void set_callback_func(callback_struct);

#ifdef TEST_LINKED

void test_func(test_funcs_struct *p);
void execute() {
  printf("loaded libtest.so\n");

  test_funcs_struct p = {
    .imported_print = &print_func,
    .set_callback = &set_callback_func
  };

  printf("executing test_func:\n");
  test_func(&p);

  if (_callback_inst.callback) {
    printf("calling callback\n");
    (*_callback_inst.callback)();
  }

  printf("finished\n");
  exit(EXIT_SUCCESS);
}

#else // TEST_LINKED

#include <dlfcn.h>

void execute() {
  void *handle;
  void (*test_func)(test_funcs_struct *p);
  char *error;

  handle = dlopen("libtest.so", RTLD_LAZY);
  if (!handle) {
    fprintf(stderr, "%s\n", dlerror());
    exit(EXIT_FAILURE);
  }

  printf("loaded libtest.so\n");
  dlerror();

  *(void **)(&test_func) = dlsym(handle, "test_func");

  if ((error = dlerror()) != NULL)  {
    fprintf(stderr, "%s\n", error);
    exit(EXIT_FAILURE);
  }

  test_funcs_struct p = {
    .imported_print = &print_func,
    .set_callback = &set_callback_func
  };
  
  printf("executing test_func:\n");
  (*test_func)(&p);

  if (_callback_inst.callback) {
    printf("calling callback\n");
    (*_callback_inst.callback)();
  }

  printf("finished\n");
  dlclose(handle);
  exit(EXIT_SUCCESS);
}

#endif // TEST_LINKED

void print_func(const char *msg) {
  printf("%s", msg);
}

void set_callback_func(callback_struct c) {
  printf("setting callback\n");
  _callback_inst = c;
}

int main(void) {
  execute();
  return 0;
}
