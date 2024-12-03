#include <iostream>
#include <vector>
#include <assert.h>

#pragma comment(lib, "libs.lib")

extern "C" __declspec(dllimport) int _stdcall  sort_stdcall_noarg(int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _cdecl    sort_cdecl_noarg(int* a, int length, int* pos_res, int* neg_res, int* neg_count);
extern "C" __declspec(dllimport) int _fastcall sort_fastcall_noarg(int* a, int length, int* pos_res, int* neg_res, int* neg_count);

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
void test_function(TestedFunction func_to_test) {
    test_function1(func_to_test);
    test_function2(func_to_test);
    test_function3(func_to_test);
    test_function4(func_to_test);
    test_function5(func_to_test);
    test_function6(func_to_test);
	test_function7(func_to_test);
}

int main() {
	test_function(sort_stdcall_noarg);
	//test_function(sort_cdecl_noarg);
	sort_fastcall_noarg(NULL, 2, NULL, NULL, NULL);
	sort_cdecl_noarg(NULL, 2, NULL, NULL, NULL);

	return 0;
}