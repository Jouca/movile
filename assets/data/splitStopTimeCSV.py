import os

# get stop_times.csv from the directory
def getFiles(directory):
    files = []
    for file in os.listdir(directory):
        if file == "stop_times.csv":
            files.append(file)
    return files

# split stop_times.csv into multiple files
def splitStopTimeCSV(directory, files):
    for file in files:
        with open(directory + file, 'r') as f:
            lines = f.readlines()
            header = lines[0]
            data = lines[1:]
            count = 0
            counter = 1
            with open(directory + "stop_times_1.csv", 'w') as f:
                f.write(header)
            for i in data:
                with open(directory + "stop_times_" + str(counter) + ".csv", 'a') as f:
                    f.write(i)
                    count += 1
                if count == len(data) // 5:
                    counter += 1
                    count = 0
                    with open(directory + "stop_times_" + str(counter) + ".csv", 'w') as f:
                        f.write(header)

# main function
def main():
    # get the path of the directory automatically
    directory = os.path.dirname(os.path.realpath(__file__)) + "/"
    files = getFiles(directory)
    print(files)
    splitStopTimeCSV(directory, files)

if __name__ == "__main__":
    main()