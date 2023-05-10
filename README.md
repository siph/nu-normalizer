# nu-normalizer

This is a batch audio normalizer. This performs dual-pass loudnorm audio
normalization using `ffmpeg`. For a more full-featured application check
[`ffmpeg-normalize`](https://github.com/slhck/ffmpeg-normalize).

## How to Use

### Nix

The best way to run this application is to use
[`nix`](https://nixos.org/download.html). `Nix` will include all the
dependencies needed to run the application.

```shell
# Run from this repository directory.
nix run .#nu-normalizer -- -r -d /path/to/directory

# Run from remote repository.
nix run github:siph/yt-watcher#nu-normalizer -- -r -d /path/to/directory
```

### Nushell

If you have `ffmpeg` installed and a compatible version of `nushell` (0.79.0)
you can run `nu-normalizer` directly

```
# Pass into fresh nushell instance.
nu nu-normalizer.nu -r -d /path/to/directory/

# Create environment with script shebang.
./nu-normalizer.nu -r -d /path/to/directory/
```

## How it works

Learn more about loudnorm [here](http://k.ylo.ph/2016/04/04/loudnorm.html)
