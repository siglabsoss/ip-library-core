import os
import sys
import subprocess


def get_files(path):
    files = (file for file in os.listdir(path) if os.path.isfile(os.path.join(path, file)))
    return files

def find_tests(path):

    # do not look in these folders
    blacklist = ['.\\.git', '.\\.idea','.\\template']

    # file name we are looking for
    target = 'go.ps1'

    # must be under this folder
    parent_dir = 'sim'

    # results
    tests = []

    for root, dirs, files in os.walk(".", topdown=False):

        skipdir = False
        for black in blacklist:
            if root.startswith(black):
                skipdir = True
                break

        if skipdir:
            continue


        for name in files:
            fpath = os.path.join(root, name)
            if fpath.endswith(target) and parent_dir in fpath:
                tests.append(fpath)
            # print("fname", fpath)
        # for name in dirs:
        #     print("dname", os.path.join(root, name))


    return tests


## Runs the selected command, looks for the success string
# stdout and stderror are printed
# ONLY stdout is searched for success tag
def run_win_cmd(cmd):
    result = []
    sdout = []
    sderror = []
    success = b'<<TB_SUCCESS>>'
    tagfound = 0
    process = subprocess.Popen(cmd,
                               shell=True,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    for line in process.stdout:
        print(line.decode("utf-8"), end="")
        result.append(line)
        if success in line:
            tagfound += 1
        # sdout.append(line)

    for line in process.stderr:
        result.append(line)
        print(line.decode("utf-8"), end="")
        # sderror.append(line)

    print ("\r\n\r\nTest Success message found", tagfound, "times")

    errcode = process.returncode
    # for line in result:
    #     print(line.decode("utf-8"), end="")
    # if errcode is not None:
    #     raise Exception('cmd %s failed, see above for details', cmd)

    return tagfound > 0

def chop(input):
    rhs = '\\go.ps1'
    assert input.endswith(rhs)

    res1 = input.index(rhs)

    # print ("asdf", res1)
    # str1.index(str2)

    lhs = input[:res1 + 1]

    return (lhs,rhs)



if __name__ == '__main__':

    mode = None
    if len(sys.argv) > 1:
        mode = sys.argv[1]

    # depending on how we are called we might need to cd
    os.chdir('..\\')
    cwd = os.getcwd()

    tests = find_tests('.')

    if mode is not None:
        if mode == 'help':
            print("\nUSAGE:\n")
            print("    `python run_tests.py`           - run all tests")
            print("    `python run_tests.py help`      - help")
            print("    `python run_tests.py list`      - list tests")
            print("    `python run_tests.py name`      - run all tests with name in the path")
            print("")
            sys.exit(0)
        if mode == 'list':
            print("\nAll tests found:\n")
            for path in tests:
                print("  -->", str(path))
            sys.exit(0)
        else:
            test_filtered = []
            substring = mode
            for path in tests:
                if substring in str(path):
                    test_filtered.append(path)
            tests = test_filtered # overwrite original

            print(len(tests), "tests with", substring, "were found")
            for path in tests:
                print("  -->", str(path))
    else:
        print("Running all tests")
        for path in tests:
            print("  -->", str(path))

    ############# Actual running of tests #############

    test_pass = []  # indexed Bools if passed

    # tests = ['ldpc_encoder\\sim\\go.ps1']
    # tests = ['.\\dds\\sim\\test_data\\go.ps1']
    # tests = ['.\\dds\\sim\\test_enable\go.ps1']

    llen = len(tests)

    chopped_folders = [] # indexed bools of short names
    failed_tests = [] # variable length of failures
    # run_win_cmd('dir asdlkja')

    for fullname in tests:
        (test_dir, _) = chop(fullname)

        # test_dir = 'ldpc_encoder\\sim\\'
        test_name = '.\\go.ps1'

        os.chdir(test_dir)

        print("cd to", os.getcwd())

        # returns true for passing
        result = run_win_cmd('powershell.exe -ExecutionPolicy Bypass ' + test_name)

        # save if test passed
        test_pass.append(result)

        if not result:
            failed_tests.append(test_dir)

        # save this variable for later
        chopped_folders.append(test_dir)

        # bail to home dir
        os.chdir(cwd)
        pass

    allpass = False not in test_pass

    numpass = test_pass.count(True)
    numfail = test_pass.count(False)

    print("\r\n\r\n------------------------------------\r\n", llen, "Tests ran.\r\n")
    if allpass:
        print("\r\n  All Tests Passed\r\n\r\n")
    print(numpass, "Passed")
    print(numfail, "Failed")

    if not allpass:
        print("\r\n\r\nList of Failed tests:")
        for path in failed_tests:
            print("  -->", path)

    print("\r\n\r\n------------------------------------")


    if allpass:
        sys.exit(0)
    else:
        sys.exit(1)

