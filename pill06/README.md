# Generic Builder

>>  generalize the builder script, write a Nix expression for GNU hello world and create a wrapper around the derivation built-in function.

## Packaging GNU hello world

We packaged a `simple.c` file (previously), which was being compiled with a raw gcc call. That's not a good example of a project. Many use autotools, and since we're going to generalize our builder, it would be better to do it with the most used build system.
> `GNU hello world`, despite its name, is a simple yet complete project which uses autotools

`hello_builder.sh`
```bash

```