#include <stdio.h>

/// __global__ device 上的函数
__global__ void hello_world(void) { printf("GPU: Hello world!\n"); }

int main(int argc, char **argv) {
    printf("CPU: Hello world!\n");
    hello_world<<<1, 10>>>();  // 10个线程

    /// 与GPU同步，防止主线程退出
    // if no this line ,it can not output hello world from gpu
    cudaDeviceReset();
    return 0;
}
