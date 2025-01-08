#include <iostream>
#include <vector>
#include <assert.h>
#include <chrono>

#pragma comment(lib, "libs.lib")

extern "C" __declspec(dllimport) int _stdcall  sort_stdcall_noarg  (int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _cdecl    sort_cdecl_noarg    (int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _fastcall sort_fastcall_noarg (int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _stdcall  sort_stdcall        (int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _cdecl    sort_cdecl          (int* a, int length, int* pos_res, int* neg_res, int* neg_count);

int sort_native(int* a, int length, int* pos_res, int* neg_res, int* neg_count) {
	int pos_count = 0;
	*neg_count = 0;
	
	for (int i = 0; i < length; i++) {
		if (a[i] > 0) {
			int j = pos_count;
			while (j > 0 && pos_res[j - 1] > a[i]) {
				pos_res[j] = pos_res[j - 1];
				j--;
			}

			pos_res[j] = a[i];
			pos_count++;
		} else {
			int j = *neg_count;
			while (j > 0 && neg_res[j - 1] > a[i]) {
				neg_res[j] = neg_res[j - 1];
				j--;
			}

			neg_res[j] = a[i];
			(*neg_count)++;
		}
	}

	return pos_count;
}

template <typename TestedFunction>
void test_function1(TestedFunction func_to_test) {
	int a[] = { -1, -2, -3, -4, -5, -6 };
	int pos_res[6] = {};
	int neg_res[6] = {};
	int neg_count;
	auto pos_count = func_to_test(a, 6, pos_res, neg_res, (int*)(&neg_count));

	assert(pos_count == 0);
	assert(neg_count == 6);
	assert(
		neg_res[0] == -6 &&
		neg_res[1] == -5 &&
		neg_res[2] == -4 &&
		neg_res[3] == -3 &&
		neg_res[4] == -2 &&
		neg_res[5] == -1);
}

template <typename TestedFunction>
void test_function2(TestedFunction func_to_test) {
	int a[] = { 6, 5, 4, 3, 2, 1 };
	int pos_res[6] = {};
	int neg_res[6] = {};
	int neg_count;
	auto pos_count = func_to_test(a, 6, pos_res, neg_res, (int*)(&neg_count));

	assert(pos_count == 6);
	assert(neg_count == 0);
	assert(
		pos_res[0] == 1 &&
		pos_res[1] == 2 &&
		pos_res[2] == 3 &&
		pos_res[3] == 4 &&
		pos_res[4] == 5 &&
		pos_res[5] == 6);
}

template <typename TestedFunction>
void test_function3(TestedFunction func_to_test) {
	int a[] = { -1, 2, -3, 3, 45, -6 };
	int pos_res[6] = {};
	int neg_res[6] = {};
	int neg_count;
	auto pos_count = func_to_test(a, 6, pos_res, neg_res, (int*)(&neg_count));

	assert(pos_count == 3);
	assert(neg_count == 3);
	assert(
		neg_res[0] == -6 &&
		neg_res[1] == -3 &&
		neg_res[2] == -1 &&
		pos_res[0] == 2 &&
		pos_res[1] == 3 &&
		pos_res[2] == 45);
}

template <typename TestedFunction>
void test_function4(TestedFunction func_to_test) {
	int a[] = { -6, -5, -4, -3, -2, -1 };
	int pos_res[6] = {};
	int neg_res[6] = {};
	int neg_count;
	auto pos_count = func_to_test(a, 6, pos_res, neg_res, (int*)(&neg_count));

	assert(pos_count == 0);
	assert(neg_count == 6);
	assert(
		neg_res[0] == -6 &&
		neg_res[1] == -5 &&
		neg_res[2] == -4 &&
		neg_res[3] == -3 &&
		neg_res[4] == -2 &&
		neg_res[5] == -1);
}

template <typename TestedFunction>
void test_function5(TestedFunction func_to_test) {
	int a[] = { 1, 2, 3, 4, 5, 6 };
	int pos_res[6] = {};
	int neg_res[6] = {};
	int neg_count;
	auto pos_count = func_to_test(a, 6, pos_res, neg_res, (int*)(&neg_count));

	assert(pos_count == 6);
	assert(neg_count == 0);
	assert(
		pos_res[0] == 1 &&
		pos_res[1] == 2 &&
		pos_res[2] == 3 &&
		pos_res[3] == 4 &&
		pos_res[4] == 5 &&
		pos_res[5] == 6);
}

template <typename TestedFunction>
void test_function6(TestedFunction func_to_test) {
	int a[] = { 6, 3, 4, 2, 1, 5 };
	int pos_res[6] = {};
	int neg_res[6] = {};
	int neg_count;
	auto pos_count = func_to_test(a, 6, pos_res, neg_res, (int*)(&neg_count));

	assert(pos_count == 6);
	assert(neg_count == 0);
	assert(
		pos_res[0] == 1 &&
		pos_res[1] == 2 &&
		pos_res[2] == 3 &&
		pos_res[3] == 4 &&
		pos_res[4] == 5 &&
		pos_res[5] == 6);
}

template <typename TestedFunction>
void test_function7(TestedFunction func_to_test) {
	int a[] = { -4, -2, -6, -1, -5, -3 };
	int pos_res[6] = {};
	int neg_res[6] = {};
	int neg_count;
	auto pos_count = func_to_test(a, 6, pos_res, neg_res, (int*)(&neg_count));

	assert(pos_count == 0);
	assert(neg_count == 6);
	assert(
		neg_res[0] == -6 &&
		neg_res[1] == -5 &&
		neg_res[2] == -4 &&
		neg_res[3] == -3 &&
		neg_res[4] == -2 &&
		neg_res[5] == -1);
}

template <typename TestedFunction>
void stress_test(TestedFunction func_to_test, int amount) {
	srand(0);
	int *a = (int*)malloc(sizeof(int) * amount);
	int *pos_res = (int*)malloc(sizeof(int) * amount);
	int *neg_res = (int*)malloc(sizeof(int) * amount);
	int neg_count;
	for (int i = 0; i < amount; i++) {
		a[i] = rand() % 1000;
	}

	std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();
	auto pos_count = func_to_test(a, amount, pos_res, neg_res, (int*)(&neg_count));
	std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
	auto delta = std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();

	std::cout << "Working time: " << delta / 1000.0 << std::endl;

	free(a);
	free(pos_res);
	free(neg_res);
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
	std::cout << "__cdecl auto parameters:" << std::endl;
	test_function(sort_cdecl);
	std::cout << "__stdcall auto parameters:" << std::endl;
	test_function(sort_stdcall);
	std::cout << "__fastcall manual parameters:" << std::endl;
	test_function(sort_fastcall_noarg);
	std::cout << "__stdcall manual parameters" << std::endl;
	test_function(sort_stdcall_noarg);
	std::cout << "__cdecl manual parameters" << std::endl;
	test_function(sort_cdecl_noarg);

	return 0;
}