#include <iostream>
#include <vector>
#include <fstream>
#include <cstdlib>
#include <ctime>

using namespace std;

typedef unsigned int uint;
typedef vector<vector<int> > matrix;

void create_graph_file(const char* path) {
    ofstream file(path);
    uint n_rows = 3;//10 + rand() % 10;
    uint n_cols = n_rows;//10 + rand() % 10;
    int maxn = 3, tmp, d = 0;
    
    file<<n_rows<<endl<<n_cols<<endl;
    
    for (uint i = 0; i < n_rows; ++i) {
	for (uint j = 0; j < n_rows; ++j) {
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
    
    uint n_cols, n_rows;
    int tmp;
    
    file>>n_rows>>n_cols;
    
    matrix graph(n_rows, vector<int>(n_cols));
    
    cout<<"n_rows = "<<n_rows<<" n_cols = "<<n_cols<<endl;
    
    for (uint i = 0; i < n_rows; ++i) {
	for (uint j = 0; j < n_cols; ++j) {
	    file>>tmp;
	    graph[i][j] = tmp;
	}
    }
    
    file.close();
    
    return graph;
}

void print_matrix(const matrix& m) {
    for (uint i = 0; i < m.size(); ++i) {
	for (uint j = 0; j < m[0].size(); ++j) {
	    printf("%3d ", m[i][j]);
	}
	cout<<endl;
    }
    cout<<endl;
}

matrix apsp(const matrix& graph) {
    uint n = graph.size();
    matrix result = graph;
    
    for (uint i = 0; i < n; ++i) {
        for (uint j = 0; j < n; ++j) {
	    for (uint k = 0; k < n; ++k) {
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
    cout<<"Hi\n";
    srand(time(0));
    const char* path = "graph_matrix.txt";
    
    create_graph_file(path);
    matrix graph = parse_file(path), shortest_paths = apsp(graph);
    print_matrix(graph);
    print_matrix(shortest_paths);
    
    return 0;
} catch(const char* str) {
    cout<<str<<endl;
}
