#!/bin/bash

if [[ -d preserved_cache ]]; then
	echo "Restoring preserved_cache into build/cache..."
	mv preserved_cache build/cache
fi

if [[ -d preserved_output ]]; then
	echo "Restoring preserved_output into build/output..."
	mv preserved_output build/output
fi

echo "Done restore run."
