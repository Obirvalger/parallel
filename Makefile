CF = -std=c++11 -fopenmp -O3 -o
TARGET = main main_p test test_p

all: $(TARGET)

main: main.cpp
	g++  main.cpp $(CF) main

main_p: main_p.cpp
	g++  main_p.cpp $(CF) main_p

test: test.cpp
	g++  test.cpp $(CF) test
	
test_p: test_p.cpp
	g++  test_p.cpp $(CF) test_p

clean:
	rm -rf $(TARGET) *.o
