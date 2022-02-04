#!/bin/sh

while inotifywait --event modify src/*.gleam ; do gleam check; done

