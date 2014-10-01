
#include <iostream>
#include <vector>
#include <fstream>
#include <cstdlib>
#include <ctime>

using namespace std;

int main(int argc, char** argv) {
    int n = 2000;
    //~ static int m[10000][10000];
    int **A = new int*[n];
    for(int i=0; i<n; i++)
        A[i]=new int[n];
	
    A[0][0] = 5;
}
