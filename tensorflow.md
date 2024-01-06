# TensorFlow on Apple M3 Pro


Guidance:
- https://medium.com/@murphy.crosby/building-tensorflow-and-tensorflow-text-on-a-m1-mac-9b90d55e92df
  - https://gist.github.com/TeoZosa/da88a858ad73a18e3f7410c4b615466d


## Xcode v15.1

```bash
% /usr/bin/xcodebuild -version
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance

% pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
version: 15.1.0.0.1.1700200546
```

Download Xcode vs 15 from [App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

```bash
 % /usr/bin/xcodebuild -version                                       
Xcode 15.1
Build version 15C65

% xcrun -f ld                                                        
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld

% ld -v
@(#)PROGRAM:ld  PROJECT:dyld-1022.1
BUILD 13:21:42 Nov 10 2023
configured to support archs: armv6 armv7 armv7s arm64 arm64e arm64_32 i386 x86_64 x86_64h
will use ld-classic for: armv6 armv7 armv7s arm64_32 i386 armv6m armv7k armv7m armv7em
LTO support using: LLVM version 15.0.0 (static support for 29, runtime is 29)
TAPI support using: Apple TAPI version 15.0.0 (tapi-1500.0.12.8)
Library search paths:
Framework search paths:
```


## Bazel v6.1.0

The project you're trying to build requires **Bazel 6.1.0** (I tried 7.0.0).

https://bazel.build/install/bazelisk#install-with-installer-mac-os-x

```bash
% export BAZEL_VERSION=6.1.0
% curl -fLO "https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-darwin-arm64.sh"
% chmod +x "bazel-$BAZEL_VERSION-installer-darwin-arm64.sh"
% ./bazel-$BAZEL_VERSION-installer-darwin-arm64.sh --user
...
Bazel is now installed!

Make sure you have "/Users/marksusol/bin" in your path.
```

Let's add the Bazel PATH to our `~/.zprofile` file.

```shell
~ $ echo "" >> ~/.zprofile
~ $ echo "# Bazel (user)" >> ~/.zprofile
~ $ echo "PATH=\"/Users/marksusol/bin:\${PATH}\"" >> ~/.zprofile
~ $ echo "export PATH" >> ~/.zprofile
~ $ echo "export MACOSX_DEPLOYMENT_TARGET=14.2 " >> ~/.zprofile
~ $ source ~/.zprofile
```

You can confirm Bazel is installed successfully by running the following command:

```shell
~ % bazel --version
bazel 6.1.0
```

## Building TensorFlow 


```shell
~ % pip --version
pip 23.3.2 from /Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages/pip (python 3.11)
```

### TensorFlow v2.15.0


To set TensorFlow's Python version, add to `~/.zprofile`:

```shell
~ $ echo "" >> ~/.zprofile
~ $ echo "# Setting Tensorflow python version" >> ~/.zprofile
~ $ echo "export TF_PYTHON_VERSION=3.11" >> ~/.zprofile
~ $ source ~/.zprofile
```


```shell
GitHub % git clone --branch v2.15.0 https://github.com/tensorflow/tensorflow.git
GitHub % cd tensorflow
tensorflow % which python3        
/Library/Frameworks/Python.framework/Versions/3.11/bin/python3

tensorflow % python3 -m venv .venv
tensorflow % source .venv/bin/activate
(.venv) tensorflow % pip install --upgrade pip
(.venv) tensorflow % pip3 install numpy==1.26.2 wheel==0.42.0 packaging==23.2 requests==2.31.0 opt-einsum==3.3.0
(.venv) tensorflow % pip3 install Keras-Preprocessing==1.1.2 --no-deps
(.venv) tensorflow % ./configure

You have bazel 6.1.0 installed.
Please specify the location of python. [Default is /Users/marksusol/DataScience/GitHub/tensorflow/.venv/bin/python3]: /Users/marksusol/DataScience/GitHub/tensorflow/.venv/bin/python3 


Found possible Python library paths:
  /Users/marksusol/DataScience/GitHub/tensorflow/.venv/lib/python3.11/site-packages
Please input the desired Python library path to use.  Default is [/Users/marksusol/DataScience/GitHub/tensorflow/.venv/lib/python3.11/site-packages]
/Users/marksusol/DataScience/GitHub/tensorflow/.venv/lib/python3.11/site-packages
Do you wish to build TensorFlow with ROCm support? [y/N]: N
No ROCm support will be enabled for TensorFlow.

Do you wish to build TensorFlow with CUDA support? [y/N]: N
No CUDA support will be enabled for TensorFlow.

Please specify optimization flags to use during compilation when bazel option "--config=opt" is specified [Default is -Wno-sign-compare]: -Wno-sign-compare

Would you like to interactively configure ./WORKSPACE for Android builds? [y/N]: N
Not configuring the WORKSPACE for Android builds.

Do you wish to build TensorFlow with iOS support? [y/N]: N
No iOS support will be enabled for TensorFlow.

Preconfigured Bazel build configs. You can use any of the below by adding "--config=<>" to your build command. See .bazelrc for more details.
        --config=mkl            # Build with MKL support.
        --config=mkl_aarch64    # Build with oneDNN and Compute Library for the Arm Architecture (ACL).
        --config=monolithic     # Config for mostly static monolithic build.
        --config=numa           # Build with NUMA support.
        --config=dynamic_kernels        # (Experimental) Build kernels into separate shared objects.
        --config=v1             # Build with TensorFlow 1 API instead of TF 2 API.
Preconfigured Bazel build configs to DISABLE default on features:
        --config=nogcp          # Disable GCP support.
        --config=nonccl         # Disable NVIDIA NCCL support.
Configuration finished
```


Now lets '`bazel build`' ..


```shell
(.venv) tensorflow % bazel build -c opt --config=macos_arm64 \
  --macos_minimum_os="${MACOSX_DEPLOYMENT_TARGET}" //tensorflow/tools/pip_package:build_pip_package

...
INFO: Found applicable config definition build:macos_arm64 in file /Users/marksusol/DataScience/GitHub/tensorflow/.bazelrc: --cpu=darwin_arm64 --macos_minimum_os=11.0
...
Target //tensorflow/tools/pip_package:build_pip_package up-to-date:
  bazel-bin/tensorflow/tools/pip_package/build_pip_package
INFO: Elapsed time: 5059.060s, Critical Path: 538.10s
INFO: 22267 processes: 5077 internal, 17190 local.
INFO: Build completed successfully, 22267 total actions

(.venv) tensorflow % ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
...
Sat Jan 6 00:56:29 MST 2024 : === Output wheel file is in: /tmp/tensorflow_pkg

(.venv) tensorflow % deactivate
```

### TensorFlow I/O v0.35.0

```shell
GitHub % git clone --branch v0.35.0 https://github.com/tensorflow/io.git
GitHub % cd io
io % python3 -m venv .venv
io % source .venv/bin/activate
(.venv) io % pip install --upgrade pip
(.venv) io % pip3 install setuptools==65.5.0 wheel==0.42.0
(.venv) io % pip3 wheel --no-deps -w dist .

Processing /Users/marksusol/DataScience/GitHub/io
  Preparing metadata (setup.py) ... done
Building wheels for collected packages: tensorflow-io
  Building wheel for tensorflow-io (setup.py) ... done
  Created wheel for tensorflow-io: filename=tensorflow_io-0.35.0-cp311-cp311-macosx_10_9_universal2.whl size=224677 sha256=cda769af40c3d33491e02a58e7a6380c8af7f715f1df4268e30537e95ef5ddc7
  Stored in directory: /private/var/folders/c3/gnpb2cfd5znckvplsjxhcy2r0000gn/T/pip-ephem-wheel-cache-bxg_dkqj/wheels/48/9e/e7/454ec82f221938ff824acf8da51d84098ef5c8de6c0cbdadad
Successfully built tensorflow-io

(.venv) io % ls -l dist 
total 472
-rw-r--r--  1 marksusol  staff  224677 Jan  6 00:28 tensorflow_io-0.35.0-cp311-cp311-macosx_10_9_universal2.whl
-rw-r--r--  1 marksusol  staff   12910 Jan  6 00:24 tensorflow_io_gcs_filesystem-0.35.0-cp311-cp311-macosx_10_9_universal2.whl

(.venv) io % deactivate
```

#### Python Issue ?

```python
from distutils import util
util.get_platform()

'macosx-10.9-universal2'
```

### TensorFlow Text v2.15.0

Copy the tensorflow and tensorflow-io wheels into this directory. Install 
tensorflow-io **first**, then tensorflow.

```shell
GitHub % git clone --branch v2.15.0 https://github.com/tensorflow/text.git
GitHub % cd text
text % python3 -m venv .venv
text % source .venv/bin/activate
(.venv) text % pip install --upgrade pip

(.venv) text % cp ../io/dist/tensorflow_io_gcs_filesystem-0.35.0-cp311-cp311-macosx_10_9_universal2.whl \
  tensorflow_io_gcs_filesystem-0.35.0-cp311-cp311-macosx_10_9_universal2.whl
(.venv) text % cp /tmp/tensorflow_pkg/tensorflow-2.15.0-cp311-cp311-macosx_11_0_arm64.whl \
  tensorflow-2.15.0-cp311-cp311-macosx_11_0_arm64.whl  # See note below.
  
(.venv) text % pip3 install tensorflow_io_gcs_filesystem-0.35.0-cp311-cp311-macosx_10_9_universal2.whl
(.venv) text % pip3 install tensorflow-2.15.0-cp311-cp311-macosx_11_0_arm64.whl

(.venv) text % pip3 list | grep tensorflow

tensorflow                   2.15.0
tensorflow-estimator         2.15.0
tensorflow-io-gcs-filesystem 0.35.0

(.venv) text % deactivate
```

TODO: Find out how to explicitly set this for `cp311`, if it matters.
https://github.com/bazelbuild/bazel/issues/20779

> Doesn't work of course.
> `ERROR: tensorflow-2.15.0-cp310-cp310-macosx_11_0_arm64.whl is not a 
> supported wheel on this platform.`
>
> **Workaround:** Since I do NOT have python3.10 installed anywhere, I don't 
> know why this gets set as `cp310`. So I will "simply" rename the file and 
> it works. 
>
> ```shell
> (.venv) text % cp /tmp/tensorflow_pkg/tensorflow-2.15.0-cp310-cp310-macosx_11_0_arm64.whl \
>   tensorflow-2.15.0-cp311-cp311-macosx_11_0_arm64.whl
> ```

Next you need to edit `./oss_scripts/pip_package/setup.py` and remove the 
`tensorflow-macos` line from the requirements. This messes up the tensorflow wheel we just created when we install it later. It essentially installs `tensorflow-macos` on top of `tensorflow`.

```python
    install_requires=[
    (
        'tensorflow>=2.15.0, <2.16; platform_machine != "arm64" or'
        ' platform_system != "Darwin"'
    ),
    #(
    #    'tensorflow-macos>=2.15.0, <2.16; platform_machine == "arm64" and'
    #    ' platform_system == "Darwin"'
    #),
    'tensorflow_hub>=0.13.0',
],
```

and now ...

```shell
 (.venv) text % ./oss_scripts/run_build.sh

ImportError: Python version mismatch: module was compiled for Python 3.10, but the interpreter version is incompatible: 3.11.7 (v3.11.7:fa7a6f2303, Dec  4 2023, 15:22:56) [Clang 13.0.0 (clang-1300.0.29.30)]
```

TODO: Complete after figuiring out `cp310` to `cp311` issue.

This one doesn’t take near as long. When it’s complete you should have tensorflow_text-2.10.0-cp39-cp39-macosx_11_0_arm64.whl

Now you can copy all three wheels into a new directory and install them and watch the magic.

```python
# python3.9 -m venv .venv
# source .venv/bin/activate
# pip install tensorflow_io_gcs_filesystem-0.27.0-cp39-cp39-macosx_13_0_arm64.whl
# pip install tensorflow-2.10.1-cp39-cp39-macosx_13_0_arm64.whl
# pip install tensorflow_text-2.10.0-cp39-cp39-macosx_11_0_arm64.whl
# pip install tensorflow-metal==0.6.0
```

Run python, import tensorflow and tensorflow_text…then profit?


Like I mentioned above, if you want to bypass all this razzmatazz and just download the wheels, go to my Google Drive and download away.

I also want to give credit to TeoZosa for his repo here. This didn’t quite work for me, but it gave me some ideas and helped me figure some things out.