#!/bin/bash
profile=$(asusctl profile -p | sed s:'Active profile is '::)
echo "{\"text\": \"$profile\", \"class\": \"$profile\"}"
