#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <vector>

using std::cout;
using std::generate;
using std::vector;

class Matrix {
public:
    Matrix(int filas, int columnas)
    {
        this->filas = filas;
        this->columnas = columnas;
        this->data = new int* [filas];
        for (int i = 0; i < filas; i++)
        {
            this->data[i] = new int[columnas];
        }
    }

    void print() {
        for (int i = 0; i < this->filas; i++)
        {
            std::cout << "|";
            for (int j = 0; j < this->columnas; j++)
            {
                std::cout << " " << this->data[i][j] << " ";
            }
            std::cout << "|";
            std::cout << std::endl;
        }
        std::cout << std::endl;
    }

    void Matrix::aleatorizar() {
        for (size_t i = 0; i < this->filas; i++)
        {
            for (size_t j = 0; j < this->columnas; j++)
            {
                //Genera numero aleatorio entre -1 y 1
                this->data[i][j] = (-1) + static_cast <int> (rand()) / (static_cast <int> (RAND_MAX / (1 - (-1))));
            }
        }
    }

    void Matrix::aleatorizarRango(int rango1, int rango2) {
        for (size_t i = 0; i < this->filas; i++)
        {
            for (size_t j = 0; j < this->columnas; j++)
            {
                //Genera numero aleatorio entre -1 y 1
                this->data[i][j] = (rango1) + static_cast <int> (rand()) / (static_cast <int> (RAND_MAX / (rango2 - (-1))));
            }
        }
    }

    int* Matrix::toVector() {
        int* res = new int[this->filas * this->columnas];
        int k = 0;
        for (int i = 0; i < this->filas; i++)
        {
            for (int j = 0; j < this->columnas; j++)
            {
                res[k] = this->data[i][j];
                k++;
            }
        }
        return res;
    }

    static Matrix* Matrix::toMatrix(int* matrix, int filas, int columnas) {
        Matrix* resultado = new Matrix(filas, columnas);
        int k = 0;
        for (int i = 0; i < filas; i++)
        {
            for (int j = 0; j < columnas; j++)
            {
                resultado->data[i][j] = matrix[k];
                k++;
            }
        }
        return resultado;
    }

    static Matrix* Matrix::multiplicar(Matrix* A, Matrix* B) {
        Matrix* resultado = new Matrix(A->filas, B->columnas);
        int suma = 0;
        for (short i = 0; i < resultado->filas; i++)
        {
            for (short j = 0; j < resultado->columnas; j++)
            {
                suma = 0;
                for (short k = 0; k < A->columnas; k++)
                {
                    suma += A->data[i][k] * B->data[k][j];
                }
                resultado->data[i][j] = suma;
            }
        }
        return resultado;
    }

    int** data;
    int filas, columnas;
private:
};

__global__ void matrixMul(int* A, int* B, int* C, 
                          int aF, int aC,
                          int bF, int bC,
                          int cF, int cC) {
    // Compute each thread's global row and column index
    int row = (blockIdx.y * blockDim.y) + threadIdx.y;
    int col = (blockIdx.x * blockDim.x) + threadIdx.x;

    // Iterate over row, and down column
    ////c[row * N + col] = 0;
    if (aC != bF) return;
    if ((row < aF) && (col < bC)) {
        for (int k = 0; k < aC; ++k) {
            // Accumulate results for a single element
            C[row * cC + col] += A[row * aC + k] * B[k * bC + col];
        }
    }
    //C[row * aF + col] = 0;
}

int main()
{
    srand(time(NULL));
    //Matriz A
    Matrix* A = new Matrix(25, 25);
    A->aleatorizarRango(0, 20);
    A->print();
    int* h_A = A->toVector();

    //Matriz B
    Matrix* B = new Matrix(25, 20);
    B->aleatorizarRango(0, 20);
    B->print();
    int* h_B = B->toVector();

    //Matrix* C = Matrix::multiplicar(A, B);
    //C->print();
    Matrix* C = new Matrix(A->filas, B->columnas);
    C->aleatorizarRango(0, 20);
    C->print();
    int* h_C = C->toVector();

    Matrix* res = Matrix::multiplicar(A,B);
    res->print();

    int* d_A;
    int sizeA = sizeof(int) * A->filas * A->columnas;
    int* d_B;
    int sizeB = sizeof(int) * B->filas * B->columnas;
    int* d_C;
    int sizeC = sizeof(int) * C->filas * C->columnas;

    // Allocate device memory
    if(cudaMalloc((void**)&d_A, sizeA) != cudaSuccess)
        std::cout << "Error al despachar A en memoria." << std::endl;
    if(cudaMalloc((void**)&d_B, sizeB) != cudaSuccess)
        std::cout << "Error al despachar B en memoria." << std::endl;
    if(cudaMalloc((void**)&d_C, sizeC) != cudaSuccess)
        std::cout << "Error al despachar C en memoria." << std::endl;

    // Copy data to the device
    if(cudaMemcpy(d_A, h_A, sizeA, cudaMemcpyHostToDevice) != cudaSuccess)
        std::cout << "Error en MemCpy (A)." << std::endl;
    if(cudaMemcpy(d_B, h_B, sizeB, cudaMemcpyHostToDevice) != cudaSuccess)
        std::cout << "Error en MemCpy (B)." << std::endl;

    // Threads per CTA dimension
    //int THREADS = 32;

    // Blocks per grid dimension (assumes THREADS divides N evenly)
    //int BLOCKS = N / THREADS;
    int BLOCKS = 1;

    // Use dim3 structs for block and grid dimensions
    dim3 threads(C->columnas, C->filas);
    //dim3 blocks(A->filas, B->columnas);

    // Launch kernel
    matrixMul << <1, threads >> > (d_A, d_B, d_C, A->filas, A->columnas, B->filas, B->columnas, C->filas, C->columnas);

    cudaError_t cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    // Copy back to the host
    if(cudaMemcpy(h_C, d_C, sizeC, cudaMemcpyDeviceToHost) != cudaSuccess)
        std::cout << "Error en MemCpy (C)." << std::endl;
    Matrix* D = Matrix::toMatrix(h_C, C->filas, C->columnas);
    D->print();

    cout << "COMPLETED SUCCESSFULLY\n";

    // Free memory on device
    Error:
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}