#include <iostream>
#include <vector>
#include <assert.h>
#include <chrono>

#pragma comment(lib, "libs.lib")

extern "C" __declspec(dllimport) int* _stdcall  sort_stdcall_noarg  (int* a, int start, int end, int* res);
extern "C" __declspec(dllimport) int* _cdecl    sort_cdecl_noarg    (int* a, int start, int end, int* res);
/*extern "C" __declspec(dllimport) int _fastcall sort_fastcall_noarg (int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _stdcall  sort_stdcall        (int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _cdecl    sort_cdecl          (int* a, int length, int* pos_res, int* neg_res, int* neg_count);*/

int* sort_native(int* a, int start, int end, int* res) {
	int i = 0;
	int length = 0;
	while (start <= end) {
		res[i++] = a[start++];
		length++;
	}

	if (length <= 1) return res;

	for (i = 0; i < length - 1; i++) {
		int min_element = res[i];
		int min_element_index = i;

		for (int j = i + 1; j < length; j++) {
			if (res[j] < min_element) {
				min_element_index = j;
				min_element = res[j];
			}
		}

		int tmp = min_element;
		res[min_element_index] = res[i];
		res[i] = min_element;
	}

	return res;
}

template <typename TestedFunction>
void test_function1(TestedFunction func_to_test) {
	int a[] = { -1, -2, -3, -4, -5, -6 };
	int sort_res[6] = {};
	auto res = func_to_test(a, 0, 5, sort_res);

	assert(res == sort_res);
	assert(
		sort_res[0] == -6 &&
		sort_res[1] == -5 &&
		sort_res[2] == -4 &&
		sort_res[3] == -3 &&
		sort_res[4] == -2 &&
		sort_res[5] == -1);
}

template <typename TestedFunction>
void test_function2(TestedFunction func_to_test) {
	int a[] = { 6, 5, 4, 3, 2, 1 };
	int sort_res[4] = {};
	auto res = func_to_test(a, 1, 4, sort_res);

	assert(res == sort_res);
	assert(
		sort_res[0] == 2 &&
		sort_res[1] == 3 &&
		sort_res[2] == 4 &&
		sort_res[3] == 5);
}

template <typename TestedFunction>
void test_function3(TestedFunction func_to_test) {
	int a[] = { -1, 2, -3, 3, 45, -6 };
	int sort_res[6] = {};
	auto res = func_to_test(a, 0, 5, sort_res);

	assert(res == sort_res);
	assert(
		sort_res[0] == -6 &&
		sort_res[1] == -3 &&
		sort_res[2] == -1 &&
		sort_res[3] == 2 &&
		sort_res[4] == 3 &&
		sort_res[5] == 45);
}

template <typename TestedFunction>
void test_function4(TestedFunction func_to_test) {
	int a[] = { -6, -5, -4, -3, -2, -1 };
	int sort_res[6] = {};
	auto res = func_to_test(a, 0, 5, sort_res);

	assert(res == sort_res);
	assert(
		sort_res[0] == -6 &&
		sort_res[1] == -5 &&
		sort_res[2] == -4 &&
		sort_res[3] == -3 &&
		sort_res[4] == -2 &&
		sort_res[5] == -1);
}

template <typename TestedFunction>
void test_function5(TestedFunction func_to_test) {
	int a[] = { 1, 2, 3, 4, 5, 6 };
	int sort_res[6] = {};
	auto res = func_to_test(a, 0, 5, sort_res);

	assert(res == sort_res);
	assert(
		sort_res[0] == 1 &&
		sort_res[1] == 2 &&
		sort_res[2] == 3 &&
		sort_res[3] == 4 &&
		sort_res[4] == 5 &&
		sort_res[5] == 6);
}

template <typename TestedFunction>
void test_function6(TestedFunction func_to_test) {
	int a[] = { 6, 3, 4, 2, 1, 5 };
	int sort_res[6] = {};
	auto res = func_to_test(a, 0, 5, sort_res);

	assert(res == sort_res);
	assert(
		sort_res[0] == 1 &&
		sort_res[1] == 2 &&
		sort_res[2] == 3 &&
		sort_res[3] == 4 &&
		sort_res[4] == 5 &&
		sort_res[5] == 6);
}

template <typename TestedFunction>
void test_function7(TestedFunction func_to_test) {
	int a[] = { -4, -2, -6, -1, -5, -3 };
	int sort_res[6] = {};
	auto res = func_to_test(a, 0, 5, sort_res);

	assert(res == sort_res);
	assert(
		sort_res[0] == -6 &&
		sort_res[1] == -5 &&
		sort_res[2] == -4 &&
		sort_res[3] == -3 &&
		sort_res[4] == -2 &&
		sort_res[5] == -1);
}

template <typename TestedFunction>
void stress_test(TestedFunction func_to_test, int amount) {
	srand(0);
	int *a = (int*)malloc(sizeof(int) * amount);
	int *sort_res = (int*)malloc(sizeof(int) * amount);
	for (int i = 0; i < amount; i++) {
		a[i] = rand() % 1000;
	}

	std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();
	auto res = func_to_test(a, 0, amount - 1, sort_res);
	std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
	auto delta = std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();

	std::cout << "Working time: " << delta / 1000.0 << std::endl;

	free(a);
	free(sort_res);
}

template <typename TestedFunction>
void test_function(TestedFunction func_to_test) {
    test_function1(func_to_test);
    test_function2(func_to_test);
    test_function3(func_to_test);
    test_function4(func_to_test);
    test_function5(func_to_test);
    test_function6(func_to_test);
	test_function7(func_to_test);
	for (int i = 10000; i <= 25000; i += 1000) {
		stress_test(func_to_test, i);
	}
}

int main() {
	std::cout << "Native function:" << std::endl;
	test_function(sort_native);
	/*std::cout << "__cdecl auto parameters:" << std::endl;
	test_function(sort_cdecl);
	std::cout << "__stdcall auto parameters:" << std::endl;
	test_function(sort_stdcall);
	std::cout << "__fastcall manual parameters:" << std::endl;
	test_function(sort_fastcall_noarg);*/
	std::cout << "__stdcall manual parameters" << std::endl;
	test_function(sort_stdcall_noarg);
	std::cout << "__cdecl manual parameters" << std::endl;
	test_function(sort_cdecl_noarg);

	

	return 0;
}