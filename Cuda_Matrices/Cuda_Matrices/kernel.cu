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

__global__ void matrixMul(const Matrix* A, const Matrix* B, Matrix* C) {
    // Compute each thread's global row and column index
    int col = (blockIdx.y * blockDim.y) + threadIdx.y;
    int row = (blockIdx.x * blockDim.x) + threadIdx.x;

    // Iterate over row, and down column
    //c[row * N + col] = 0;
    for (int k = 0; k < A->filas; k++) {
        // Accumulate results for a single element
        //c[row * N + col] += a[row * N + k] * b[k * N + col];
        //C->data[row][col] += A->data[row][k] * B->data[k][row];
        C->data[row][col] = 0;
    }
}

int main()
{
    srand(time(NULL));
    //Matriz A
    Matrix* A = new Matrix(3, 3);
    A->aleatorizarRango(0, 20);
    A->print();

    //Matriz B
    Matrix* B = new Matrix(3, 2);
    B->aleatorizarRango(0, 20);
    B->print();

    //Matrix* C = Matrix::multiplicar(A, B);
    //C->print();
    Matrix* C = new Matrix(A->filas, B->columnas);
    C->aleatorizar();
    C->print();

    Matrix* d_A = A;//(Matrix*)malloc(sizeof(Matrix));
    Matrix* d_B = B;
    Matrix* d_C = C;

    // Allocate device memory
    cudaMalloc(&d_A, sizeof(Matrix));
    cudaMalloc(&d_B, sizeof(Matrix));

    // Copy data to the device
    cudaMemcpy(&d_A, &A, sizeof(Matrix), cudaMemcpyHostToDevice);
    cudaMemcpy(&d_B, &B, sizeof(Matrix), cudaMemcpyHostToDevice);

    // Threads per CTA dimension
    //int THREADS = 32;

    // Blocks per grid dimension (assumes THREADS divides N evenly)
    //int BLOCKS = N / THREADS;
    int BLOCKS = 1;

    // Use dim3 structs for block and grid dimensions
    dim3 threads(A->filas, B->columnas);
    dim3 blocks(BLOCKS);

    // Launch kernel
    matrixMul << <blocks, threads >> > (d_A, d_B, d_C);

    // Copy back to the host
    cudaMemcpy(&C, &d_C, sizeof(Matrix), cudaMemcpyDeviceToHost);
    C->print();
    // Check result
    //verify_result(h_a, h_b, h_c, N);
    //print_result(h_a, h_b, h_c, N);

    cout << "COMPLETED SUCCESSFULLY\n";

    // Free memory on device
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}