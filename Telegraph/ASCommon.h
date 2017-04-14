/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef ActionStage_ASCommon_h  /*防止该头文件被重复引用*/
#define ActionStage_ASCommon_h

#include <inttypes.h>

//#define DISABLE_LOGGING

#define INTERNAL_RELEASE

//#define EXTERNAL_INTERNAL_RELEASE

#ifdef __cplusplus             //__cplusplus是cpp中自定义的一个宏
extern "C" {                   //告诉编译器，这部分代码按C语言的格式进行编译，而不是C++的
#endif

void TGLogSetEnabled(bool enabled);
bool TGLogEnabled();
void TGLog(NSString *format, ...);
void TGLogv(NSString *format, va_list args);

void TGLogSynchronize();
NSArray *TGGetLogFilePaths(int count);
NSArray *TGGetPackedLogs();
    
#ifdef __cplusplus
}
#endif

#endif
