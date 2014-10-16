#include <iostream>
#include <vector>
#include <fstream>
#include <cstdlib>
#include <ctime>
#include <omp.h>

using namespace std;

typedef unsigned int uint;
typedef vector<vector<int> > matrix;

matrix parse_file(const char* path) {
    ifstream file(path);
    
    uint n;
    int tmp;
    
    file>>n;
    
    matrix graph(n, vector<int>(n));
    
    for (uint i = 0; i < n; ++i) {
	for (uint j = 0; j < n; ++j) {
	    file>>tmp;
	    graph[i][j] = tmp;
	}
    }
    
    file.close();
    
    return graph;
}

void print_matrix(const matrix& m, const char *path = "") {
    if (path == "") {
	for (uint i = 0; i < m.size(); ++i) {
	    for (uint j = 0; j < m[0].size(); ++j) {
		cout<<m[i][j]<<' ';
	    }
	    cout<<endl;
	}
	cout<<endl;
    } else {
	ofstream out(path);
	for (uint i = 0; i < m.size(); ++i) {
	    for (uint j = 0; j < m[0].size(); ++j) {
		out<<m[i][j]<<' ';
	    }
	    out<<endl;
	}
	out<<endl;
    }
    
}

matrix floyd(const matrix& graph) {
    uint n = graph.size();
    matrix result = graph;

    #pragma omp parallel for schedule(dynamic, 10)
    for (uint k = 0; k < n; ++k) {
	for (uint i = 0; i < n; ++i) {
	    for (uint j = 0; j < n; ++j) {
		if (result[i][k] >= 0 && result[k][j] >= 0) {
		    if (result[i][j] == -1 || result[i][k] + result[k][j] < result[i][j])
			result[i][j] = result[i][k] + result[k][j];
		}
            }
        }
    }
    
    return result;
}

int main(int argc, char** argv) try {
    srand(time(0));
    const char* in_path = (argc > 1) ? argv[1] : "graph_matrix.txt";
    const char* out_path = (argc > 2) ? argv[2] : "graph_matrix.txt";
    
    double lt = omp_get_wtime();
    matrix graph = parse_file(in_path);
    matrix shortest_paths = floyd(graph);
    print_matrix(shortest_paths, out_path);
    printf("Time is equal %g\n", omp_get_wtime() - lt);
    
    return 0;
} catch(const char* str) {
    cout<<str<<endl;
}
