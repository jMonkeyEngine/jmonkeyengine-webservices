#!/bin/bash

echo "" > build.html
echo "<style>" >> build.html
cat style.css >> build.html
echo "</style>" >> build.html
echo '<script src="https://cdnjs.cloudflare.com/ajax/libs/later/1.2.0/later.min.js" integrity="sha512-4OyNDMl5KLKjS8F1ImVwUvmthM8HkXbR6vMafCmT5zBTd9I/sA3z3zM0JLBosHW6/3K2jq2RoBo/eTUNS2hOGA==" crossorigin="anonymous"></script>' >> build.html
echo "<script>" >> build.html
cat index.js >> build.html
echo "</script>" >> build.html

