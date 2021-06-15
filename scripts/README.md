
# Test Runner

## Purpose

This python script crawls the entire repo
looking for files named `go.ps1`.  This allows for multiple tests under `sim/`, for instance:

```
ip-library\
  dds\
	  sim\
		  test_data\go.ps1
			test_enable\go.ps1
```

## Requirements

All tests must print `<<TB_SUCCESS>>` to `stdout` (not `stderr`).  If this string is missing
the test is marked as failed.


## Usage

command | Result
------------ | -------------
`python run_tests.py` | Run all tests
`python run_tests.py help` | Shows help for command
`python run_tests.py list` | Lists all tests it will be running
`python run_tests.py name` | Runs tests that have `name` as a substring of the path


## Notes
* Automated tests are run on the `dev` and `master` branches, results are posted do the `#alerts-jenkins` Slack channel.
* The `run_tests.py` script will return `1` if any of the tests fail, and `0` otherwise.  In the case of a filtered run (`python run_tests.py dds` for example), only tests that match `dds` will affect the exit code of the script.
