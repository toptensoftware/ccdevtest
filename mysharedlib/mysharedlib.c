#ifdef _MSC_VER
__declspec(dllexport)
#endif
int MySharedFunction(int a, int b)
{
    return a + b;
}