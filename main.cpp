#include <iostream>
#include <vector>
#include <fstream>
#include <cstdlib>
#include <ctime>

using namespace std;

typedef vector<vector<int> > matrix;
typedef unsigned int uint;

void create_graph_file(const char* path) {
    ofstream file(path);
    uint n_rows = 10 + rand() % 10;
    uint n_cols = n_rows;//10 + rand() % 10;
    uint maxn = 10;
    
    file<<n_rows<<endl<<n_cols<<endl;
    
    for (int i = 0; i < n_rows; ++i) {
	for (int j = 0; j < n_rows; ++j) {
	    file<<(rand() % maxn)<<" ";
	}
	
	file<<endl;
    }
    
}

matrix parse_file(const char* path = "main.cpp") {
    ifstream file(path);
    matrix graph;
    
    uint n, n_cols, n_rows;
    char c;
    
    file>>n_rows>>c>>n_cols>>c;
    
    return graph;
}

int main(int argc, char** argv) {
    cout<<"Hi\n";
    srand(time(0));
    const char* path = "graph_matrix.txt";
    
    create_graph_file(path);
    
    matrix graph = parse_file(path);
    
    return 0;
}
