# sescode: SEcure Source CODE

### Usage:
```
$ bundle install
$ ruby main.rb -h
```

```
Usage: ruby main.rb [options]
    -f, --file FILEPATH              Required file to process
    -o, --output FILEPATH            Output path
    -v, --[no-]verbose               Run verbosely
    -a, --algorithm ALGORITHM        Hash algorithm used
    -l, --language LANGUAGE          Language used in source code
        --random-size SIZE           Salt seed size in bytes
        --discard-size SIZE          Discarded seed size when refreshing between the hash
    -h, --help                       Display this help message

```
