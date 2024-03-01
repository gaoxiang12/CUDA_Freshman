#include <cuda_runtime.h>
#include <stdio.h>

#include "freshman.h"
#include "timer.h"

void sumArrays(float *a, float *b, float *res, const int size) {
    for (int i = 0; i < size; i += 4) {
        res[i] = a[i] + b[i];
        res[i + 1] = a[i + 1] + b[i + 1];
        res[i + 2] = a[i + 2] + b[i + 2];
        res[i + 3] = a[i + 3] + b[i + 3];
    }
}

/// GPU上的求和
__global__ void sumArraysGPU(float *a, float *b, float *res) {
    // int i=threadIdx.x;
    /// blockIdx, blockDim, threadIdx都是cuda的built-in
    // 级别：blockIdx, blockDim, threadIdx
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    res[i] = a[i] + b[i];
}

int main(int argc, char **argv) {
    int dev = 0;
    cudaSetDevice(dev);

    int nElem = 1 << 15;
    printf("Vector size:%d\n", nElem);
    int nByte = sizeof(float) * nElem;
    float *a_h = (float *)malloc(nByte);
    float *b_h = (float *)malloc(nByte);
    float *res_h = (float *)malloc(nByte);
    float *res_from_gpu_h = (float *)malloc(nByte);
    memset(res_h, 0, nByte);
    memset(res_from_gpu_h, 0, nByte);

    /// 分配gpu的内存
    float *a_d, *b_d, *res_d;
    CHECK(cudaMalloc((float **)&a_d, nByte));
    CHECK(cudaMalloc((float **)&b_d, nByte));
    CHECK(cudaMalloc((float **)&res_d, nByte));

    /// 填入随机数
    initialData(a_h, nElem);
    initialData(b_h, nElem);

    /// 拷贝至GPU
    CHECK(cudaMemcpy(a_d, a_h, nByte, cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(b_d, b_h, nByte, cudaMemcpyHostToDevice));

    dim3 block(1024);
    dim3 grid(nElem / block.x);

    agi::Timer::Evaluate(
        [&]() {
            sumArraysGPU<<<grid, block>>>(a_d, b_d, res_d);
            printf("Execution configuration<<<%d,%d>>>\n", grid.x, block.x);
        },
        "sum GPU");

    /// 拷回来
    CHECK(cudaMemcpy(res_from_gpu_h, res_d, nByte, cudaMemcpyDeviceToHost));

    agi::Timer::Evaluate([&]() { sumArrays(a_h, b_h, res_h, nElem); }, "sum CPU");

    /// 检查这n个数是否一样
    checkResult(res_h, res_from_gpu_h, nElem);
    cudaFree(a_d);
    cudaFree(b_d);
    cudaFree(res_d);

    free(a_h);
    free(b_h);
    free(res_h);
    free(res_from_gpu_h);

    agi::Timer::PrintAll();

    return 0;
}
