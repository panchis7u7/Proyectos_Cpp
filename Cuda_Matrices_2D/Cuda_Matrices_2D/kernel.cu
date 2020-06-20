#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "Matrix.h"
#include <stdio.h>

int main()
{  
    Matrix<int>* A = new Matrix<int>(13,13);
    A->aleatorizarRango(0, 10);
    A->print();

    Matrix<int>* B = new Matrix<int>(3, 2);
    B->aleatorizarRango(0,10);
    B->print();

    float* d_A = nullptr;
    float* d_B = nullptr;
    size_t pitch_A;
    size_t pitch_B;

    if (cudaMallocPitch((void**)&d_A, &pitch_A, sizeof(float)*A->columnas, A->filas) != cudaSuccess)
        std::cout << "Error al crear memoria (A)." << std::endl;
    if (cudaMallocPitch((void**)&d_B, &pitch_B, sizeof(float) * B->columnas, B->filas) != cudaSuccess)
        std::cout << "Error al crear memoria (B)." << std::endl;

    if(cudaMemcpy2D(d_A, pitch_A, A->datos, sizeof(float) * A->columnas, sizeof(float) * A->columnas, A->filas, cudaMemcpyHostToDevice) != cudaSuccess)
        std::cout << "Error al copiar en memoria (A)." << std::endl;
    if (cudaMemcpy2D(d_B, pitch_B, B->datos, sizeof(float) * B->columnas, sizeof(float) * B->columnas, B->filas, cudaMemcpyHostToDevice) != cudaSuccess)
        std::cout << "Error al copiar en memoria (B)." << std::endl;

    Matrix<int>* D = new Matrix<int>(A->filas, A->columnas);
    if (cudaMemcpy2D(D->datos, sizeof(float) * D->columnas, d_A, pitch_A, sizeof(float) * A->columnas, A->filas, cudaMemcpyDeviceToHost) != cudaSuccess)
        std::cout << "Error al copiar en memoria (D)." << std::endl;
    D->print();
    return 0;
}
