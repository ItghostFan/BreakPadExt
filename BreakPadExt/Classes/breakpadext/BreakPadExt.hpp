//
//  BreakPadExt.hpp
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/10.
//

#ifndef BreakPadExt_hpp
#define BreakPadExt_hpp

#include <assert.h>
#import <Foundation/Foundation.h>
#include <pthread.h>
#include <sys/stat.h>
#include <sys/sysctl.h>

#include "exception_handler.h"
#include "simple_string_dictionary.h"
#include "ConfigFile.h"

using google_breakpad::ConfigFile;
using google_breakpad::EnsureDirectoryPathExists;
using google_breakpad::SimpleStringDictionary;

class Breakpad {
 public:
  // factory method
  static Breakpad *Create(NSDictionary *parameters);

  ~Breakpad();

  void SetKeyValue(NSString *key, NSString *value);
  NSString *KeyValue(NSString *key);
  void RemoveKeyValue(NSString *key);
  NSArray *CrashReportsToUpload();
  NSString *NextCrashReportToUpload();
  void UploadNextReport(NSDictionary *server_parameters);
  void UploadData(NSData *data, NSString *name,
                  NSDictionary *server_parameters);
  NSDictionary *GenerateReport(NSDictionary *server_parameters);

 protected:
  Breakpad();

  bool Initialize(NSDictionary *parameters);

  bool ExtractParameters(NSDictionary *parameters);

  // Dispatches to HandleMinidump()
  static bool HandleMinidumpCallback(const char *dump_dir,
                                     const char *minidump_id,
                                     void *context, bool succeeded);

  bool HandleMinidump(const char *dump_dir,
                      const char *minidump_id);

  // NSException handler
  static void UncaughtExceptionHandler(NSException *exception);

  // Handle an uncaught NSException.
  void HandleUncaughtException(NSException *exception);

  // Since ExceptionHandler (w/o namespace) is defined as typedef in OSX's
  // MachineExceptions.h, we have to explicitly name the handler.
  google_breakpad::ExceptionHandler *handler_; // The actual handler (STRONG)

  SimpleStringDictionary  *config_params_; // Create parameters (STRONG)

  ConfigFile config_file_;

  // A static reference to the current Breakpad instance. Used for handling
  // NSException.
  static Breakpad *current_breakpad_;
};

class BreakPadExt : public Breakpad {
public:
    static Breakpad *Create(NSDictionary *parameters);

    BreakPadExt();
    ~BreakPadExt();
};


#endif /* BreakPadExt_hpp */
