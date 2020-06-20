#include "Matrix.h"

// Uploaded by panchis7u7 ~ Sebastian Madrigal

template<typename T>
Matrix<T>::Matrix(int filas, int columnas) {
	this->filas = filas;
	this->columnas = columnas;
	this->datos = new T* [this->filas];
	for (int i = 0; i < this->filas; i++)
	{
		this->datos[i] = new T[this->columnas];
	}
}

template<typename T>
Matrix<T>::Matrix() {
	this->datos = alloc(0,0);
}

template<typename T>
Matrix<T>::~Matrix() {
	for (size_t i = 0; i < this->filas; i++)
	{
		delete[] datos[i];
	}
	delete[] datos;
}

template<typename T>
T** Matrix<T>::alloc(int filas, int columnas) {
	this->filas = filas;
	this->columnas = columnas;
	T** datos = new T* [this->filas];
	for (size_t i = 0; i < this->filas; i++)
	{
		datos[i] = new T[this->columnas];
	}
	return datos;
}

template<typename T>
void Matrix<T>::print() {
	for (size_t i = 0; i < filas; i++)
	{
		std::cout << "|";
		for (size_t j = 0; j < columnas; j++)
		{
			std::cout << "  " << datos[i][j] << "  ";
		}
		std::cout << "|";
		std::cout << std::endl;
	}
	std::cout << std::endl;
}

template<typename T>
void Matrix<T>::suma(T n) {
	for (size_t i = 0; i < this->filas; i++)
	{
		for (size_t j = 0; j < this->columnas; j++)
		{
			this->datos[i][j] += n;
		}
	}
}

template<typename T>
void Matrix<T>::aleatorizar() {
	for (size_t i = 0; i < this->filas; i++)
	{
		for (size_t j = 0; j < this->columnas; j++)
		{
			//Genera numero aleatorio entre -1 y 1
			this->datos[i][j] = (-1) + static_cast <T> (rand()) / (static_cast <T> (RAND_MAX / (1 - (-1)))); 
		}
	}
}

template<typename T>
void Matrix<T>::aleatorizarRango(T rango1, T rango2) {
	for (size_t i = 0; i < this->filas; i++)
	{
		for (size_t j = 0; j < this->columnas; j++)
		{
			//Genera numero aleatorio entre -1 y 1
			this->datos[i][j] = (rango1)+static_cast <T> (rand()) / (static_cast <T> (RAND_MAX / (rango2 - (-1))));
		}
	}
}

template<typename T>
void Matrix<T>::suma(Matrix* sumando) {
	for (size_t i = 0; i < this->filas; i++)
	{
		for (size_t j = 0; j < this-> columnas; j++)
		{
			this->datos[i][j] += sumando->datos[i][j];
		}
	}
}

template<typename T>
void Matrix<T>::productoScalar(T n) {
	for (size_t i = 0; i < this->filas; i++)
	{
		for (size_t j = 0; j < this->columnas; j++)
		{
			this->datos[i][j] *= n;
		}
	}
}

template<typename T>
void Matrix<T>::productoHadamard(Matrix* A) {
	for (size_t i = 0; i < this->filas; i++)
	{
		for (size_t j = 0; j < this->columnas; j++)
		{
			this->datos[i][j] *= A->datos[i][j];
		}
	}
}

template<typename T>
T* Matrix<T>::toVector() {
	T* res = new T[this->filas * this->columnas];
	int k = 0;
	for (int i = 0; i < this->filas; i++)
	{
		for (int j = 0; j < this->columnas; j++)
		{
			res[k] = this->datos[i][j];
			k++;
		}
	}
	return res;
}

template<typename T>
void Matrix<T>::map(T (*func)(T)) {
	for (size_t i = 0; i < this->filas; i++)
	{
		for (size_t j = 0; j < this->columnas; j++)
		{
			this->datos[i][j] = func(this->datos[i][j]);
		}
	}
}

template class Matrix<int>;
template class Matrix<float>;
template class Matrix<double>;