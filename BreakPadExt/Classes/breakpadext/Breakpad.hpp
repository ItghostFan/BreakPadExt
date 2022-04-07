//
//  Breakpad.hpp
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/17.
//

#ifndef Breakpad_hpp
#define Breakpad_hpp

#import <Foundation/Foundation.h>
#include <sys/sysctl.h>

#import "client/mac/handler/exception_handler.h"
#import "common/long_string_dictionary.h"
#include "client/mac/crash_generation/ConfigFile.h"
#import "client/mac/handler/protected_memory_allocator.h"

using google_breakpad::ConfigFile;
using google_breakpad::LongStringDictionary;

extern ProtectedMemoryAllocator *gMasterAllocator;
extern ProtectedMemoryAllocator *gKeyValueAllocator;
extern ProtectedMemoryAllocator *gBreakpadAllocator;

class Breakpad {
 public:
  // factory method
  static Breakpad* Create(NSDictionary* parameters) {
    // Allocate from our special allocation pool
    Breakpad* breakpad =
      new (gBreakpadAllocator->Allocate(sizeof(Breakpad)))
        Breakpad();

    if (!breakpad)
      return NULL;

    if (!breakpad->Initialize(parameters)) {
      // Don't use operator delete() here since we allocated from special pool
      breakpad->~Breakpad();
      return NULL;
    }

    return breakpad;
  }

  ~Breakpad();

  void SetKeyValue(NSString* key, NSString* value);
  NSString* KeyValue(NSString* key);
  void RemoveKeyValue(NSString* key);
  NSArray* CrashReportsToUpload();
  NSString* NextCrashReportToUpload();
  NSDictionary* NextCrashReportConfiguration();
  NSDictionary* FixedUpCrashReportConfiguration(NSDictionary* configuration);
  NSDate* DateOfMostRecentCrashReport();
  void UploadNextReport(NSDictionary* server_parameters);
  void UploadReportWithConfiguration(NSDictionary* configuration,
                                     NSDictionary* server_parameters,
                                     BreakpadUploadCompletionCallback callback);
  void UploadData(NSData* data, NSString* name,
                  NSDictionary* server_parameters);
  void HandleNetworkResponse(NSDictionary* configuration,
                             NSData* data,
                             NSError* error);
  NSDictionary* GenerateReport(NSDictionary* server_parameters);

 protected:
  Breakpad()
    : handler_(NULL),
      config_params_(NULL) {}

  bool Initialize(NSDictionary* parameters);

  bool ExtractParameters(NSDictionary* parameters);

  // Dispatches to HandleMinidump()
  static bool HandleMinidumpCallback(const char* dump_dir,
                                     const char* minidump_id,
                                     void* context, bool succeeded);

  bool HandleMinidump(const char* dump_dir,
                      const char* minidump_id);

  // NSException handler
  static void UncaughtExceptionHandler(NSException* exception);

  // Handle an uncaught NSException.
  void HandleUncaughtException(NSException* exception);

  // Since ExceptionHandler (w/o namespace) is defined as typedef in OSX's
  // MachineExceptions.h, we have to explicitly name the handler.
  google_breakpad::ExceptionHandler* handler_; // The actual handler (STRONG)

  LongStringDictionary* config_params_; // Create parameters (STRONG)

  ConfigFile config_file_;

  // A static reference to the current Breakpad instance. Used for handling
  // NSException.
  static Breakpad* current_breakpad_;
};

#endif /* Breakpad_hpp */
