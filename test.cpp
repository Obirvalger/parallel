#include <iostream>
#include <vector>
#include <fstream>
#include <cstdlib>
#include <ctime>

using namespace std;

typedef unsigned int uint;

int main(int argc, char** argv) {
    srand(time(0));
    uint n = atoi(argv[1]);
    int **graph = new int*[n];
    for(int i=0; i<n; i++)
        graph[i]=new int[n];
    int maxn = 3, tmp, d = 0;
    
    //initializing of graph matrix
    for (uint i = 0; i < n; ++i) {
	for (uint j = 0; j < n; ++j) {
	    tmp = rand() % (maxn + 1) - d; 
	    if (i == j) 
		graph[i][j] = 0;
	    else
		graph[i][j] = ((tmp > 0) ? tmp + d : -1);
	}
    }
    
    time_t lt = time(0);
    
    //computing all paths
    for (uint i = 0; i < n; ++i) {
        for (uint j = 0; j < n; ++j) {
	    for (uint k = 0; k < n; ++k) {
		if (graph[i][k] >= 0 && graph[k][j] >= 0) {
		    if (graph[i][j] == -1 || graph[i][k] + graph[k][j] < graph[i][j])
			graph[i][j] = graph[i][k] + graph[k][j];
		}
            }
        }
    }
    
    cout<<(time(0) - lt)<<endl;
    for (int i = 0; i < n; ++i) {
	delete graph[i];
    }
    delete graph;
    return 0;
}
