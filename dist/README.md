# TensorFlow Wheels for Apple M3 Pro

Download all [three wheels](../dist) into a new directory to install for 
silicon Macs:

```shell
~ % pip install tensorflow_io_gcs_filesystem-0.34.0-cp311-cp311-macosx_14_0_universal2.whl
~ % pip install tensorflow-2.15.0-cp311-cp311-macosx_14_0_arm64.whl
~ % pip install tensorflow_text-2.15.0-cp311-cp311-macosx_11_0_arm64.whl

~ % pip list | grep tensorflow

tensorflow                   2.15.0
tensorflow-estimator         2.15.0
tensorflow-hub               0.15.0
tensorflow-io-gcs-filesystem 0.34.0
tensorflow-macos             2.15.0
tensorflow-text              2.15.0
```

## Git LFS

ref: [Configuring Git Large File Storage](https://docs.github.com/en/repositories/working-with-files/managing-large-files/configuring-git-large-file-storage)

### Install

```shell
~ % sudo port install git-lfs
~ % sudo port load rsync
~ % sudo port select --set ruby ruby31
--->  Loading startupitem 'rsyncd' for rsync
Selecting 'ruby31' for 'ruby' succeeded. 'ruby31' is now active.

~ % git lfs install             
Updated Git hooks.
Git LFS initialized.
```

### Git Commit

To commit the `whl` files that exceed 100 MB, we need to use `git lfs`.

Track, add, and commit as follows:

```shell
~ % cd dist
dist % git lfs track "*.whl"
Tracking "*.whl"

# `.whl` files already copied to this directory.
dist % git add tensorflow*.whl
dist % git commit -m 'tensorflow*.whl files added'
```
