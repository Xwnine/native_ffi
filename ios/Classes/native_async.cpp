//
// Created by GZ05022ML on 2021/10/16.
//

// C
#include <stdio.h>

// Unix
#include <unistd.h>
#include <pthread.h>

#include "dart_api/dart_api.h"
#include "dart_api/dart_native_api.h"

#include "dart_api/dart_api_dl.h"
#include <string.h>

// Initialize `dart_api_dl.h`
DART_EXPORT intptr_t InitDartApiDL(void* data) {
  return Dart_InitializeApiDL(data);
}

Dart_Port send_port_;

DART_EXPORT void RegisterSendPort(Dart_Port send_port) {
  send_port_ = send_port;
}

DART_EXPORT void MockPostCObject() {
  int j = 1000;
  while (j >= 0) {
    const char* p1 = "abcdebaadddcciippjjdfffwegegeefdgas";
    char* p2 = (char*)malloc(sizeof(char) * 200);
    memcpy(p2, p1, 200);
    Dart_CObject c_buff;
    c_buff.type = Dart_CObject_kInt64;
    c_buff.value.as_int64 = reinterpret_cast<intptr_t>(p2);
    Dart_PostCObject_DL(send_port_, &c_buff);
    --j;
  }
}

DART_EXPORT void FreeCppPointer(void *ptr) {
  if (ptr != nullptr) {
    free(ptr);
  }
}

typedef void (*VoidCallbackFunc)();

void *thread_func0(void *args) {
  printf("thread_func Running on (%p)\n", pthread_self());
  sleep(1 /* seconds */); // doing something

  Dart_CObject dart_object;
  dart_object.type = Dart_CObject_kInt64;
  dart_object.value.as_int64 = reinterpret_cast<intptr_t>(args);
  Dart_PostCObject_DL(send_port_, &dart_object);
  pthread_exit(args);
}

void *thread_func1(void *args) {
  while (1) {
    sleep(1 /* seconds */); // doing something
    MockPostCObject();
  }
}

void *thread_func2(void *args) {
  MockPostCObject();
  pthread_exit(args);
}

void TestCase1(VoidCallbackFunc callback) {
  pthread_t callback_thread;
  pthread_create(&callback_thread, NULL, thread_func1, (void *)callback);
}

void TestCase2(VoidCallbackFunc callback) {
  pthread_t callback_thread;
  pthread_create(&callback_thread, NULL, thread_func2, (void *)callback);
}

void TestCase3() {
  MockPostCObject();
}

DART_EXPORT void NativeAsyncCallback(VoidCallbackFunc callback) {
  printf("NativeAsyncCallback Running on (%p)\n", pthread_self());
//  TestCase3();
  TestCase2(callback);
  TestCase1(callback);
}
