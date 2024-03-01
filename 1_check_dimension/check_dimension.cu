#include <cuda_runtime.h>
#include <stdio.h>
#include <iostream>

__global__ void checkIndex(void) {
    printf(
        "threadIdx:(%d,%d,%d) blockIdx:(%d,%d,%d) blockDim:(%d,%d,%d)\
  gridDim(%d,%d,%d)\n",
        threadIdx.x, threadIdx.y, threadIdx.z, blockIdx.x, blockIdx.y, blockIdx.z, blockDim.x, blockDim.y, blockDim.z,
        gridDim.x, gridDim.y, gridDim.z);
}
int main(int argc, char **argv) {
    /// 从大到小： grid, block, thread

    int nElem = 6;
    dim3 block(3);
    dim3 grid((nElem + block.x - 1) / block.x);
    printf("grid.x %d grid.y %d grid.z %d\n", grid.x, grid.y, grid.z);
    printf("block.x %d block.y %d block.z %d\n", block.x, block.y, block.z);

    std::cout << std::endl;
    checkIndex<<<grid, block>>>();
    cudaDeviceReset();
    return 0;
}
