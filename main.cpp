#include <stdio.h>
#include "main.h"

extern "C"
int MySharedFunction(int a, int b);

extern "C"
int MyStaticFunction(int a, int b);


int main()
{
    printf("Calling shared lib %i\n", MySharedFunction(20, 3));
    printf("Calling static lib %i\n", MyStaticFunction(20, 3));
}

