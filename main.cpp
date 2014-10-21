#include <iostream>
#include <vector>
#include <fstream>
#include <cstdlib>
#include <ctime>
#include <omp.h>

using namespace std;

typedef unsigned int uint;
typedef vector<vector<int> > matrix;

void create_graph_file(const char* path, int n) {
    //~ cout<<"n = "<<n<<endl;
    ofstream file(path);
    int maxn = 5, tmp, d = 0;
    
    file<<n<<endl;

    for (int i = 0; i < n; ++i) {
	for (int j = 0; j < n; ++j) {
	    tmp = rand() % (maxn + 1) - d; 
	    if (i == j) 
		file<<0<<" ";
	    else
		file<<((tmp > 0) ? tmp + d : -1)<<" ";
	}
	
	file<<endl;
    }
    
    file.close();
}

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
    srand((omp_get_wtime() * 1000));
    bool in_file_create = (argc > 3)? 1 : 0;
    const char* in_path = (argc > 1) ? argv[1] : "graph_matrix.txt";
    const char* out_path = (argc > 2) ? argv[2] : "graph_matrix.txt";
    
    if (in_file_create) create_graph_file(in_path, atoi(argv[3]));
    double lt = omp_get_wtime();
    matrix graph = parse_file(in_path);
    matrix shortest_paths = floyd(graph);
    print_matrix(shortest_paths, out_path);
    printf("Time is equal %g\n", omp_get_wtime() - lt);
    
    return 0;
} catch(const char* str) {
    cout<<str<<endl;
}
