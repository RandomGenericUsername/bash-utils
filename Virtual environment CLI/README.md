# Venv CLI Tool - README

## Overview

The `venv` CLI tool is a versatile utility for managing environment variables in a bash environment. It allows users to install, set, get, delete, and list environment variables across various types, including regular variables, arrays, and associative arrays. This tool is particularly useful for managing environment configurations for scripts and applications.

---

## Table of Contents

1. [Installation](#installation)
2. [Commands](#commands)
   - [Install](#install)
   - [Set](#set)
   - [Get](#get)
   - [Delete](#delete)
   - [List](#list)
   - [Uninstall](#uninstall)
3. [Usage Examples](#usage-examples)

---

## Installation

Before using the `venv` tool, it must be installed in the desired directory. This sets up the necessary configuration files for managing environment variables.

### Install Command

The `install` command initializes the environment system in the specified directory.

### Usage:
<pre><code>
venv install /path/to/install
</code></pre>

This command creates a directory structure with a `config.sh` file and separate files for storing regular variables, arrays, and associative arrays.

---

## Commands

### Install
The `install` command sets up the environment in the specified directory, preparing it for storing and managing environment variables.

### Usage:
``` bash
venv install /path/to/install
```

### Set
The `set` command allows you to define environment variables. This command supports setting regular variables, arrays, and associative arrays.

#### Set a Regular Variable
``` bash
venv set status "active" --config /path/to/config.sh
```

#### Set an Array Variable
``` bash
venv set favorite_colors "Cyan Blue" "Green Magenta" "Red Orange" "Yellow Ocre" --config /path/to/config.sh
```


#### Set an Associative Array Variable
``` bash
venv set mode_descriptions "Battery saver":"Reduces performance to save battery" "High performance":"Maximizes performance at the cost of battery life" --config /path/to/config.sh
```

### Get
The `get` command retrieves the value of a specified environment variable. It can fetch regular variables, arrays, and associative arrays.

#### Get a Regular Variable
```
status=$(venv get status --config /path/to/config.sh)
echo "Status: $status"
```

#### Get an Array Variable
``` bash
output=$(venv get favorite_colors --config /path/to/config.sh)
eval "arr=($output)"
echo "First color: ${arr[0]}"
echo "Second color: ${arr[1]}"
echo "Third color: ${arr[2]}"
echo "Fourth color: ${arr[3]}"
```

#### Get an Associative Array Variable
``` bash
output=$(venv get mode_descriptions --config /path/to/config.sh)
declare -A descriptions
while IFS=':' read -r key value; do
    descriptions[$key]=$value
done <<< "$output"
echo "Battery Saver Mode Description: ${descriptions["Battery saver"]}"
echo "High Performance Mode Description: ${descriptions["High performance"]}"
```

### Delete

The `delete` command removes a specified environment variable from the configuration.

``` bash
venv delete status --config /path/to/config.sh
```

### List

The `list` command displays all the variables that are currently set in the configuration, including their types.

#### List All Variables
<pre><code>
venv list --config /path/to/config.sh
</code></pre>

### Uninstall

The `uninstall` command removes the environment system from the specified directory. This will delete all environment variables and their configuration files.

### Usage:
<pre><code>
venv uninstall /path/to/install
</code></pre>

---

## Usage Examples

### Installing the Venv Environment
<pre><code>
venv install /home/user/env
</code></pre>

### Setting Variables

- Regular Variable:
  <pre><code>
  venv set username "john_doe" --config /home/user/env/config.sh
  </code></pre>

- Array Variable:
  <pre><code>
  venv set languages "Python" "JavaScript" "Bash" --config /home/user/env/config.sh
  </code></pre>

- Associative Array Variable:
  <pre><code>
  venv set user_info "name:John Doe" "email:johndoe@example.com" --config /home/user/env/config.sh
  </code></pre>

### Getting Variables

- Regular Variable:
  <pre><code>
  username=$(venv get username --config /home/user/env/config.sh)
  echo "Username: $username"
  </code></pre>

- Array Variable:
  <pre><code>
  output=$(venv get languages --config /home/user/env/config.sh)
  eval "arr=($output)"
  echo "First language: ${arr[0]}"
  </code></pre>

- Associative Array Variable:
  <pre><code>
  output=$(venv get user_info --config /home/user/env/config.sh)
  declare -A user_info
  while IFS=':' read -r key value; do
      user_info[$key]=$value
  done <<< "$output"
  echo "User Name: ${user_info["name"]}"
  </code></pre>

### Deleting Variables

- Regular Variable:
  <pre><code>
  venv delete username --config /home/user/env/config.sh
  </code></pre>

- Array Variable:
  <pre><code>
  venv delete languages --config /home/user/env/config.sh
  </code></pre>

- Associative Array Variable:
  <pre><code>
  venv delete user_info --config /home/user/env/config.sh
  </code></pre>

---
