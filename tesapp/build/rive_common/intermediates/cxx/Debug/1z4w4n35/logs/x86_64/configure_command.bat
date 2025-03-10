@echo off
"C:\\Users\\SISTEMAS 2\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\Users\\SISTEMAS 2\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev\\rive_common-0.4.15\\android" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=19" ^
  "-DANDROID_PLATFORM=android-19" ^
  "-DANDROID_ABI=x86_64" ^
  "-DCMAKE_ANDROID_ARCH_ABI=x86_64" ^
  "-DANDROID_NDK=C:\\Users\\SISTEMAS 2\\AppData\\Local\\Android\\sdk\\ndk\\25.1.8937393" ^
  "-DCMAKE_ANDROID_NDK=C:\\Users\\SISTEMAS 2\\AppData\\Local\\Android\\sdk\\ndk\\25.1.8937393" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Users\\SISTEMAS 2\\AppData\\Local\\Android\\sdk\\ndk\\25.1.8937393\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Users\\SISTEMAS 2\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=C:\\Users\\SISTEMAS 2\\Documents\\AppTESA\\tesapp\\build\\rive_common\\intermediates\\cxx\\Debug\\1z4w4n35\\obj\\x86_64" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=C:\\Users\\SISTEMAS 2\\Documents\\AppTESA\\tesapp\\build\\rive_common\\intermediates\\cxx\\Debug\\1z4w4n35\\obj\\x86_64" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BC:\\Users\\SISTEMAS 2\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev\\rive_common-0.4.15\\android\\.cxx\\Debug\\1z4w4n35\\x86_64" ^
  -GNinja
