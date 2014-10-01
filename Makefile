CF = -std=c++11 -x c++ -O3 -c
TARGET = main

all: $(TARGET)

main.o: main.cpp
	g++  $(CF) -c main.cpp

$(TARGET): main.o
	g++ -std=c++11 main.o -o $(TARGET)

test: test.cpp
	g++  test.cpp -std=c++11 -O3 -o test

clean:
	rm -rf $(TARGET) *.o
