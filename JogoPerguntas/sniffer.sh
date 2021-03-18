#!/bin/bash

printf "> Sniffing for bad patterns...\n"

if [ $(git config core.ignorecase) != "false" ]; then
	printf "> Local git case sensitivity set to true. Set it to false and try again."
	printf "\n> You can do so with 'git config core.ignorecase false'."
	printf "\n> Commit aborted.\n> ---\n"
	exit 1 # exit with failure status
fi

ESLINT="node_modules/eslint"
if [ ! -d "$ESLINT" ]; then
	printf "> ESLint not found at ${ESLINT}. Please check your dev environment.\n> Commit aborted.\n> ---\n"
	exit 1 # exit with failure status
fi

ERRORS=0
for file in $(git diff --cached --name-only | grep -E '\.(js|ts)$')
do
	output=`git show ":$file" | node_modules/.bin/eslint --color --stdin --stdin-filename "$file"`
	N=$(($(wc -l <<< "$output") - 1))
	ERRORS=$((ERRORS + N))
	if [ $N -ne 0 ]; then
		echo "$output"
	fi
done

for file in $(git diff --cached --name-only | grep -E '\b[A-Z]\w*\/')
do 
	printf "> ESLint failed on staged file '$file'.\n> Capitalized folder found, please comply to pattern.\n> Commit aborted.\n> ---\n"
	ERRORS=1
done

if [ $ERRORS -ne 0 ]; then
	printf "\n> At least one problem was found. Commit aborted.\n\n"
	exit 1
fi

printf "> Done sniffing, no problems found.\n\n"