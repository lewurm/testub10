#include <stdio.h>
#include <stdlib.h>

extern long callchecking();

#define RET return

int call(void)
{
#include CALL
}

long labs(long);

#ifdef DEFINE_G
long g(long x, long y)
{
  return h(x*2, y*3)+1;
}
#endif

int main(int argc, char *argv[])
{
  long r;
  r=callchecking();
  if(r==0 || r==1)
    return !r;
  return r;
}

