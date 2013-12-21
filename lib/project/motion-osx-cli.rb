# -*- coding: utf-8 -*-
#
# Copyright (c) 2012, HipByte SPRL and contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module Motion; module Project;
  class OSXConfig < XcodeConfig
    def main_cpp_file_txt(spec_objs)
      main_txt = ""
      if frameworks.include?('AppKit')
        main_txt << "#import <AppKit/AppKit.h>"
      else
        main_txt << "#import <Foundation/Foundation.h>"
      end
      main_txt << <<EOS


extern "C" {
    void rb_define_global_const(const char *, void *);
    void rb_rb2oc_exc_handler(void);
    void rb_exit(int);
    void RubyMotionInit(int argc, char **argv);
EOS
      if spec_mode
        spec_objs.each do |_, init_func|
          main_txt << "void #{init_func}(void *, void *);\n"
        end
      end
      main_txt << <<EOS
}
EOS
      if spec_mode
        main_txt << <<EOS
@interface SpecLauncher : NSObject
@end

@implementation SpecLauncher

- (void)runSpecs
{
EOS
        spec_objs.each do |_, init_func|
          main_txt << "#{init_func}(self, 0);\n"
        end
        main_txt << <<EOS
        [NSClassFromString(@\"Bacon\") performSelector:@selector(run)];
}

- (void)appLaunched:(NSNotification *)notification
{
    [self runSpecs];
}

@end
EOS
      end

      main_txt << <<EOS
int
main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
EOS
    if ENV['ARR_CYCLES_DISABLE']
      main_txt << <<EOS
    setenv("ARR_CYCLES_DISABLE", "1", true);
EOS
    end
    main_txt << <<EOS
    RubyMotionInit(argc, argv);
EOS
    if spec_mode && frameworks.include?('AppKit')
      main_txt << "SpecLauncher *specLauncher = [[SpecLauncher alloc] init];\n"
      main_txt << "[[NSNotificationCenter defaultCenter] addObserver:specLauncher selector:@selector(appLaunched:) name:NSApplicationDidFinishLaunchingNotification object:nil];\n"
    end
    main_txt << <<EOS
    NSMutableArray * arguments = [[NSMutableArray alloc] initWithCapacity: argc];
    for (int i = 0; i < argc; i++)
    {
        [arguments addObject: [NSString stringWithUTF8String: argv[i]]];
    }
    [[NSClassFromString(@"#{delegate_class}") new] performSelector:NSSelectorFromString(@"main:") withObject:[NSNumber numberWithInt:argc] withObject:arguments];
    [pool release];
    rb_exit(0);
    return 0;
}
EOS
    end
  end
end; end
